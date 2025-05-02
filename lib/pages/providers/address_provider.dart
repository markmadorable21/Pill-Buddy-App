import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:philippines_rpcmb/philippines_rpcmb.dart' as pr;

/// Manages address selection state for global and PH-specific flows.
class AddressProvider extends ChangeNotifier {
  List<csc.Country> countries = [];
  List<csc.State> states = [];
  List<csc.City> cities = [];

  csc.Country? selectedCountry;
  csc.State? selectedState;
  csc.City? selectedCity;

  bool loadingCountries = false;
  bool loadingStates = false;
  bool loadingCities = false;

  final List<pr.Region> regions = pr.philippineRegions;
  pr.Region? selectedRegion;
  pr.Province? selectedProvince;
  pr.Municipality? selectedMunicipality;
  String? selectedBarangay;

  String _inputtedAdditionalInfo = '';
  String get inputtedAdditionalInfo => _inputtedAdditionalInfo;

  AddressProvider() {
    loadCountries();
  }

  Future<void> loadCountries() async {
    loadingCountries = true;
    notifyListeners();
    countries = await csc.getAllCountries();
    loadingCountries = false;
    notifyListeners();
  }

  Future<void> setCountry(csc.Country? country) async {
    selectedCountry = country;
    selectedState = null;
    selectedCity = null;
    states = [];
    cities = [];
    selectedRegion = null;
    selectedProvince = null;
    selectedMunicipality = null;
    selectedBarangay = null;

    if (country == null) return notifyListeners();
    if (country.isoCode == 'PH') return notifyListeners();

    loadingStates = true;
    notifyListeners();
    states = await csc.getStatesOfCountry(country.isoCode);
    loadingStates = false;
    notifyListeners();
  }

  Future<void> setStateObj(csc.State? state) async {
    selectedState = state;
    selectedCity = null;
    cities = [];
    if (state == null || selectedCountry == null) return notifyListeners();

    loadingCities = true;
    notifyListeners();
    cities = await csc.getStateCities(
      selectedCountry!.isoCode,
      state.isoCode,
    );
    loadingCities = false;
    notifyListeners();
  }

  void setCity(csc.City? city) {
    selectedCity = city;
    notifyListeners();
  }

  void setRegion(pr.Region? region) {
    selectedRegion = region;
    selectedProvince = null;
    selectedMunicipality = null;
    selectedBarangay = null;
    notifyListeners();
  }

  void setProvince(pr.Province? province) {
    selectedProvince = province;
    selectedMunicipality = null;
    selectedBarangay = null;
    notifyListeners();
  }

  void setMunicipality(pr.Municipality? municipality) {
    selectedMunicipality = municipality;
    selectedBarangay = null;
    notifyListeners();
  }

  void inputAdditionalInfo(String info) {
    _inputtedAdditionalInfo = info;
    notifyListeners();
  }

  void setBarangay(String? barangay) {
    selectedBarangay = barangay;
    notifyListeners();
  }

  String _toTitleCase(String text) {
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      final lower = w.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).join(' ');
  }

  String _regionUpper(String text) => text.toUpperCase();

  String get completeAddress {
    final iso = selectedCountry?.isoCode;
    final parts = <String>[];

    if (iso == 'PH') {
      // start with additional info
      if (inputtedAdditionalInfo.isNotEmpty) {
        parts.add(_toTitleCase(inputtedAdditionalInfo));
      }
      // then barangay → municipality → province → region → country
      if (selectedBarangay != null) {
        parts.add(_toTitleCase(selectedBarangay!));
      }
      if (selectedCity != null) {
        parts.add(_toTitleCase(selectedCity!.name));
      }
      if (selectedMunicipality != null) {
        parts.add(_toTitleCase(selectedMunicipality!.name));
      }
      if (selectedProvince != null) {
        parts.add(_toTitleCase(selectedProvince!.name));
      }
      if (selectedRegion != null) {
        parts.add(_regionUpper(selectedRegion!.regionName));
      }
      if (selectedCountry != null) {
        parts.add(_toTitleCase(selectedCountry!.name));
      }
    } else {
      // non-PH: additional info → city → state → country
      if (inputtedAdditionalInfo.isNotEmpty) {
        parts.add(_toTitleCase(inputtedAdditionalInfo));
      }
      if (selectedCity != null) {
        parts.add(_toTitleCase(selectedCity!.name));
      }
      if (selectedState != null) {
        parts.add(_toTitleCase(selectedState!.name));
      }
      if (selectedCountry != null) {
        parts.add(_toTitleCase(selectedCountry!.name));
      }
    }

    return parts.join(', ');
  }
}

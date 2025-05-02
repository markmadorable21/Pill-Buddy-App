import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

class CountryStateTestPage extends StatefulWidget {
  @override
  _CountryStateTestPageState createState() => _CountryStateTestPageState();
}

class _CountryStateTestPageState extends State<CountryStateTestPage> {
  List<csc.Country> _countries = [];
  List<csc.State> _states = [];
  List<csc.City> _cities = [];
  List<String> _barangays = [];

  csc.Country? _selectedCountry;
  csc.State? _selectedState;
  csc.City? _selectedCity;
  String? _selectedBarangay;

  bool _isLoadingCountries = true;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  bool _isLoadingBarangays = false;

  // Custom overrides
  final Map<String, List<csc.City>> _customCities = {
    // Key: '<countryCode>-<stateName>'
    'PH-Misamis Oriental': [
      csc.City(
          name: 'Cagayan de Oro',
          countryCode: 'PH',
          stateCode: 'Misamis Oriental'),
      csc.City(
          name: 'Gingoog', countryCode: 'PH', stateCode: 'Misamis Oriental'),
      csc.City(
          name: 'El Salvador',
          countryCode: 'PH',
          stateCode: 'Misamis Oriental'),
    ],
  };

  final Map<String, List<String>> _customBarangays = {
    // Key: '<countryCode>-<stateName>-<cityName>'
    'PH-Misamis Oriental-Cagayan de Oro': [
      'Bulua',
      'Camaman-an',
      'Lapasan',
    ],
    'PH-Misamis Oriental-Gingoog': [
      'Balingasag Poblacion',
      'Talisayan Poblacion',
      'Hinaplanon',
    ],
    'PH-Misamis Oriental-El Salvador': [
      'Jose Dalman',
      'Mabini',
      'San Isidro',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final countries = await csc.getAllCountries();
    setState(() {
      _countries = countries;
      _isLoadingCountries = false;
    });
  }

  Future<void> _onCountryChanged(csc.Country? country) async {
    if (country == null) return;
    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _selectedCity = null;
      _selectedBarangay = null;
      _states = [];
      _cities = [];
      _barangays = [];
      _isLoadingStates = true;
    });
    final states = await csc.getStatesOfCountry(country.isoCode);
    setState(() {
      _states = states;
      _isLoadingStates = false;
    });
  }

  Future<void> _onStateChanged(csc.State? state) async {
    if (state == null) return;
    setState(() {
      _selectedState = state;
      _selectedCity = null;
      _selectedBarangay = null;
      _cities = [];
      _barangays = [];
      _isLoadingCities = true;
    });
    final key = '${_selectedCountry!.isoCode}-${state.name}';
    if (_customCities.containsKey(key)) {
      setState(() {
        _cities = _customCities[key]!;
        _isLoadingCities = false;
      });
      return;
    }
    final cities = await csc.getStateCities(
      _selectedCountry!.isoCode,
      state.isoCode,
    );
    setState(() {
      _cities = cities;
      _isLoadingCities = false;
    });
  }

  Future<void> _onCityChanged(csc.City? city) async {
    if (city == null) return;
    setState(() {
      _selectedCity = city;
      _selectedBarangay = null;
      _barangays = [];
      _isLoadingBarangays = true;
    });
    final key = '${_selectedCountry!.isoCode}-'
        '${_selectedState!.name}-'
        '${city.name}';
    if (_customBarangays.containsKey(key)) {
      setState(() {
        _barangays = _customBarangays[key]!;
        _isLoadingBarangays = false;
      });
    } else {
      // No barangay data available
      setState(() {
        _barangays = [];
        _isLoadingBarangays = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Country → State → City → Barangay')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isLoadingCountries
                ? Center(child: CircularProgressIndicator())
                : DropdownButton<csc.Country>(
                    isExpanded: true,
                    hint: Text('Select Country'),
                    value: _selectedCountry,
                    items: _countries
                        .map((c) => DropdownMenuItem(
                              child: Text(c.name),
                              value: c,
                            ))
                        .toList(),
                    onChanged: _onCountryChanged,
                  ),
            SizedBox(height: 16),
            if (_selectedCountry != null)
              _isLoadingStates
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButton<csc.State>(
                      isExpanded: true,
                      hint: Text('Select State'),
                      value: _selectedState,
                      items: _states
                          .map((s) => DropdownMenuItem(
                                child: Text(s.name),
                                value: s,
                              ))
                          .toList(),
                      onChanged: _onStateChanged,
                    ),
            SizedBox(height: 16),
            if (_selectedState != null)
              _isLoadingCities
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButton<csc.City>(
                      isExpanded: true,
                      hint: Text('Select City'),
                      value: _selectedCity,
                      items: _cities
                          .map((ct) => DropdownMenuItem(
                                child: Text(ct.name),
                                value: ct,
                              ))
                          .toList(),
                      onChanged: _onCityChanged,
                    ),
            SizedBox(height: 16),
            if (_selectedCity != null)
              _isLoadingBarangays
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('Select Barangay'),
                      value: _selectedBarangay,
                      items: _barangays
                          .map((b) => DropdownMenuItem(
                                child: Text(b),
                                value: b,
                              ))
                          .toList(),
                      onChanged: (b) => setState(() => _selectedBarangay = b),
                    ),
            SizedBox(height: 24),
            if (_selectedBarangay != null)
              Text(
                'Selected: ${_selectedCountry!.name} > ${_selectedState!.name} > ${_selectedCity!.name} > $_selectedBarangay',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

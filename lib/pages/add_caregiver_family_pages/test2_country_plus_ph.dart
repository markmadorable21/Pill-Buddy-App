import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:philippines_rpcmb/philippines_rpcmb.dart' as pr;

class CountryStateTestPage2 extends StatefulWidget {
  @override
  _CountryStateTestPageState createState() => _CountryStateTestPageState();
}

class _CountryStateTestPageState extends State<CountryStateTestPage2> {
  // Global flow variables
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

  // Philippines-specific lists and selections
  List<pr.Region> _rpcRegions = [];
  pr.Region? _rpcRegion;
  pr.Province? _rpcProvince;
  pr.Municipality? _rpcMunicipality;
  String? _rpcBarangay;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    // Load all PH regions
    _rpcRegions = pr.philippineRegions;
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
      // Reset global flow
      _selectedState = null;
      _selectedCity = null;
      _selectedBarangay = null;
      _states = [];
      _cities = [];
      _barangays = [];
      _isLoadingStates = true;
      // Reset PH flow
      _rpcRegion = null;
      _rpcProvince = null;
      _rpcMunicipality = null;
      _rpcBarangay = null;
    });
    if (country.isoCode == 'PH') {
      setState(() {
        _states = [];
        _isLoadingStates = false;
      });
    } else {
      final states = await csc.getStatesOfCountry(country.isoCode);
      setState(() {
        _states = states;
        _isLoadingStates = false;
      });
    }
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
    final cities = await csc.getStateCities(
      _selectedCountry!.isoCode,
      state.isoCode,
    );
    setState(() {
      _cities = cities;
      _isLoadingCities = false;
    });
  }

  /// Converts general text to Title Case (First letter capitalized)
  String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      final lower = word.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).join(' ');
  }

  /// Converts region names to full uppercase
  String _regionToUpperCase(String text) {
    return text.toUpperCase();
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
            // Country picker
            _isLoadingCountries
                ? Center(child: CircularProgressIndicator())
                : DropdownButton<csc.Country>(
                    isExpanded: true,
                    hint: Text('Select Country'),
                    value: _selectedCountry,
                    items: _countries
                        .map((c) => DropdownMenuItem(
                              child: Text(_toTitleCase(c.name)),
                              value: c,
                            ))
                        .toList(),
                    onChanged: _onCountryChanged,
                  ),
            SizedBox(height: 16),
            if (_selectedCountry != null) ...[
              if (_selectedCountry!.isoCode == 'PH') ...[
                // Custom Region dropdown for PH with all uppercase
                DropdownButton<pr.Region>(
                  isExpanded: true,
                  hint: Text('Select Region'),
                  value: _rpcRegion,
                  items: _rpcRegions
                      .map((r) => DropdownMenuItem(
                            child: Text(_regionToUpperCase(r.regionName)),
                            value: r,
                          ))
                      .toList(),
                  onChanged: (r) => setState(() {
                    _rpcRegion = r;
                    _rpcProvince = null;
                    _rpcMunicipality = null;
                    _rpcBarangay = null;
                  }),
                ),
                SizedBox(height: 16),
                if (_rpcRegion != null) ...[
                  DropdownButton<pr.Province>(
                    isExpanded: true,
                    hint: Text('Select Province'),
                    value: _rpcProvince,
                    items: _rpcRegion!.provinces
                        .map((p) => DropdownMenuItem(
                              child: Text(_toTitleCase(p.name)),
                              value: p,
                            ))
                        .toList(),
                    onChanged: (p) => setState(() {
                      _rpcProvince = p;
                      _rpcMunicipality = null;
                      _rpcBarangay = null;
                    }),
                  ),
                ],
                SizedBox(height: 16),
                if (_rpcProvince != null) ...[
                  DropdownButton<pr.Municipality>(
                    isExpanded: true,
                    hint: Text('Select Municipality / City'),
                    value: _rpcMunicipality,
                    items: _rpcProvince!.municipalities
                        .map((m) => DropdownMenuItem(
                              child: Text(_toTitleCase(m.name)),
                              value: m,
                            ))
                        .toList(),
                    onChanged: (m) => setState(() {
                      _rpcMunicipality = m;
                      _rpcBarangay = null;
                    }),
                  ),
                ],
                SizedBox(height: 16),
                if (_rpcMunicipality != null) ...[
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select Barangay'),
                    value: _rpcBarangay,
                    items: _rpcMunicipality!.barangays
                        .map((b) => DropdownMenuItem(
                              child: Text(_toTitleCase(b)),
                              value: b,
                            ))
                        .toList(),
                    onChanged: (b) => setState(() => _rpcBarangay = b),
                  ),
                ],
                if (_rpcBarangay != null) ...[
                  SizedBox(height: 24),
                  Text(
                    'Selected PH: ${_regionToUpperCase(_rpcRegion!.regionName)} > ${_toTitleCase(_rpcProvince!.name)} > ${_toTitleCase(_rpcMunicipality!.name)} > ${_toTitleCase(_rpcBarangay!)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ] else ...[
                // Global flow for other countries
                _isLoadingStates
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButton<csc.State>(
                        isExpanded: true,
                        hint: Text('Select State'),
                        value: _selectedState,
                        items: _states
                            .map((s) => DropdownMenuItem(
                                  child: Text(_toTitleCase(s.name)),
                                  value: s,
                                ))
                            .toList(),
                        onChanged: _onStateChanged,
                      ),
                SizedBox(height: 16),
                if (_selectedState != null) ...[
                  _isLoadingCities
                      ? Center(child: CircularProgressIndicator())
                      : DropdownButton<csc.City>(
                          isExpanded: true,
                          hint: Text('Select City'),
                          value: _selectedCity,
                          items: _cities
                              .map((ct) => DropdownMenuItem(
                                    child: Text(_toTitleCase(ct.name)),
                                    value: ct,
                                  ))
                              .toList(),
                          onChanged: (ct) => setState(() => _selectedCity = ct),
                        ),
                ],
                SizedBox(height: 16),
                if (_selectedCity != null) ...[
                  _isLoadingBarangays
                      ? Center(child: CircularProgressIndicator())
                      : DropdownButton<String>(
                          isExpanded: true,
                          hint: Text('Select Barangay'),
                          value: _selectedBarangay,
                          items: _barangays
                              .map((b) => DropdownMenuItem(
                                    child: Text(_toTitleCase(b)),
                                    value: b,
                                  ))
                              .toList(),
                          onChanged: (b) =>
                              setState(() => _selectedBarangay = b),
                        ),
                ],
                if (_selectedBarangay != null) ...[
                  SizedBox(height: 24),
                  Text(
                    'Selected: ${_toTitleCase(_selectedCountry!.name)} > ${_toTitleCase(_selectedState!.name)} > ${_toTitleCase(_selectedCity!.name)} > ${_toTitleCase(_selectedBarangay!)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ]
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:philippines_rpcmb/philippines_rpcmb.dart' as pr;

class TestAddNewCaregiverFamilyPage extends StatefulWidget {
  const TestAddNewCaregiverFamilyPage({super.key});

  @override
  _AddNewCaregiverFamilyPageState createState() =>
      _AddNewCaregiverFamilyPageState();
}

class _AddNewCaregiverFamilyPageState
    extends State<TestAddNewCaregiverFamilyPage> {
  final _formKey = GlobalKey<FormState>();
// In your State class:
  List<String> _languages = [
    'Not Specified',
    'English',
    'Español',
    'Français',
    '日本語',
    'Русский',
    'Deutsch',
    'Türk',
    // add more as needed
  ];
  String _selectedLanguage = 'Not Specified';

  List<String> _relationships = [
    'Not Specified',
    'Mother',
    'Father',
    'Husband',
    'Wife',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Other Relative',
    'Friend',
    // add more as needed
  ];
  String _selectedRelationship = 'Not Specified';
  // Personal info controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  // Gender
  String selectedGender = 'Male';

  // Date (birthdate placeholder)
  DateTime? _birthdate;

  // Global country/state/city
  List<csc.Country> _countries = [];
  List<csc.State> _states = [];
  List<csc.City> _cities = [];

  csc.Country? _selectedCountry;
  csc.State? _selectedState;
  csc.City? _selectedCity;

  bool _isLoadingCountries = true;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  // PH-specific region/province/municipality/barangay
  final List<pr.Region> _rpcRegions = pr.philippineRegions;
  pr.Region? _rpcRegion;
  pr.Province? _rpcProvince;
  pr.Municipality? _rpcMunicipality;
  String? _rpcBarangay;

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
      _states = [];
      _cities = [];
      _isLoadingStates = true;
      // Reset PH
      _rpcRegion = null;
      _rpcProvince = null;
      _rpcMunicipality = null;
      _rpcBarangay = null;
    });
    if (country.isoCode == 'PH') {
      setState(() {
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
      _cities = [];
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

  String _toTitleCase(String text) {
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      final lower = w.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).join(' ');
  }

  String _regionUpper(String text) => text.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Caregiver/Family'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Icon(
                  Icons.person_add,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Manage meds for your family member or patient',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Caregiver Info Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Row
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.isEmpty == true ? 'Enter first name' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.isEmpty == true ? 'Enter last name' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    Row(
                      children: [
                        const Icon(Icons.transgender, color: Colors.blue),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: selectedGender,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (v) => setState(() => selectedGender = v!),
                          items: ['Male', 'Female', 'Non-binary', 'Other']
                              .map((g) =>
                                  DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Birthdate picker (placeholder)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (date != null)
                                setState(() => _birthdate = date);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _birthdate == null
                                    ? 'Select Birthdate'
                                    : '${_birthdate!.month}/${_birthdate!.day}/${_birthdate!.year}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address dropdowns
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _isLoadingCountries
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButton<csc.Country>(
                                  isExpanded: true,
                                  hint: const Text('Country'),
                                  value: _selectedCountry,
                                  items: _countries
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(_toTitleCase(c.name)),
                                          ))
                                      .toList(),
                                  onChanged: _onCountryChanged,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_selectedCountry?.isoCode == 'PH') ...[
                      // PH Region
                      DropdownButton<pr.Region>(
                        isExpanded: true,
                        hint: const Text('Region'),
                        value: _rpcRegion,
                        items: _rpcRegions
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    _regionUpper(r.regionName),
                                  ),
                                ))
                            .toList(),
                        onChanged: (r) => setState(() {
                          _rpcRegion = r;
                          _rpcProvince = null;
                          _rpcMunicipality = null;
                          _rpcBarangay = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      if (_rpcRegion != null) ...[
                        DropdownButton<pr.Province>(
                          isExpanded: true,
                          hint: const Text('Province'),
                          value: _rpcProvince,
                          items: _rpcRegion!.provinces
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(_toTitleCase(p.name)),
                                  ))
                              .toList(),
                          onChanged: (p) => setState(() {
                            _rpcProvince = p;
                            _rpcMunicipality = null;
                            _rpcBarangay = null;
                          }),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (_rpcProvince != null) ...[
                        DropdownButton<pr.Municipality>(
                          isExpanded: true,
                          hint: const Text('Municipality / City'),
                          value: _rpcMunicipality,
                          items: _rpcProvince!.municipalities
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(_toTitleCase(m.name)),
                                  ))
                              .toList(),
                          onChanged: (m) => setState(() {
                            _rpcMunicipality = m;
                            _rpcBarangay = null;
                          }),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (_rpcMunicipality != null) ...[
                        DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Barangay'),
                          value: _rpcBarangay,
                          items: _rpcMunicipality!.barangays
                              .map((b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(_toTitleCase(b)),
                                  ))
                              .toList(),
                          onChanged: (b) => setState(() => _rpcBarangay = b),
                        ),
                      ],
                    ] else ...[
                      // Global state & city
                      Row(
                        children: [
                          const SizedBox(width: 32),
                          Expanded(
                            child: _isLoadingStates
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : DropdownButton<csc.State>(
                                    isExpanded: true,
                                    hint: const Text('State'),
                                    value: _selectedState,
                                    items: _states
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                _toTitleCase(s.name),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: _onStateChanged,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_selectedState != null) ...[
                        Row(
                          children: [
                            const SizedBox(width: 32),
                            Expanded(
                              child: _isLoadingCities
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : DropdownButton<csc.City>(
                                      isExpanded: true,
                                      hint: const Text('City'),
                                      value: _selectedCity,
                                      items: _cities
                                          .map((c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(
                                                  _toTitleCase(c.name),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (c) =>
                                          setState(() => _selectedCity = c),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),
                    // Additional Information
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _additionalInfoController,
                            decoration: const InputDecoration(
                              labelText: 'Additional Information',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Language dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: _languages
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedLanguage = val!),
                    ),

                    const SizedBox(height: 16),

// Caregiver’s relationship to patient dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Caregiver’s relationship to patient',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: _relationships
                          .map((rel) => DropdownMenuItem(
                                value: rel,
                                child: Text(rel),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedRelationship = val!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              // Contact Info Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5)
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _contactNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v?.isEmpty == true
                                ? 'Enter contact number'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v?.isEmpty == true
                                ? 'Enter email address'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "By clicking the 'Verify' button, you confirm that you received the consent of the dependent (when applicable) to the association of the dependent's personal information with their health information and confirm you have read and agreed to our Terms and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Navigate to terms
                },
                child: const Text(
                  'Terms and Privacy Policy',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Submit
                    }
                  },
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

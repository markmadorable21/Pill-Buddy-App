import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/providers/address_provider.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_hope_to_achieve_page.dart';
import 'package:provider/provider.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:philippines_rpcmb/philippines_rpcmb.dart' as pr;

final logger = Logger();

class SetAddressPage extends StatelessWidget {
  final _additionalInfoController = TextEditingController();

  SetAddressPage({Key? key}) : super(key: key);

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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Consumer<AddressProvider>(
          builder: (context, provider, _) {
            final iso = provider.selectedCountry?.isoCode;
            final isComplete = iso != null &&
                ((iso == 'PH' && provider.selectedBarangay != null) ||
                    (iso != 'PH' && provider.selectedCity != null));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scrollable section with all dropdowns
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.location_on, size: 80, color: primary),
                        const SizedBox(height: 8),
                        Text(
                          'Please select your address',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Country
                        provider.loadingCountries
                            ? const Center(child: CircularProgressIndicator())
                            : Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: DropdownButton<csc.Country>(
                                  isExpanded: true,
                                  hint: const Text('Country'),
                                  value: provider.selectedCountry,
                                  items: provider.countries.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text(_toTitleCase(c.name)),
                                    );
                                  }).toList(),
                                  onChanged: provider.setCountry,
                                ),
                              ),
                        const SizedBox(height: 16),

                        // Philippines flow
                        if (iso == 'PH') ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: DropdownButton<pr.Region>(
                              isExpanded: true,
                              hint: const Text('Region'),
                              value: provider.selectedRegion,
                              items: provider.regions.map((r) {
                                return DropdownMenuItem(
                                  value: r,
                                  child: Text(_regionUpper(r.regionName)),
                                );
                              }).toList(),
                              onChanged: provider.setRegion,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (provider.selectedRegion != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: DropdownButton<pr.Province>(
                                isExpanded: true,
                                hint: const Text('Province'),
                                value: provider.selectedProvince,
                                items:
                                    provider.selectedRegion!.provinces.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(_toTitleCase(p.name)),
                                  );
                                }).toList(),
                                onChanged: provider.setProvince,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (provider.selectedProvince != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: DropdownButton<pr.Municipality>(
                                isExpanded: true,
                                hint: const Text('Municipality / City'),
                                value: provider.selectedMunicipality,
                                items: provider.selectedProvince!.municipalities
                                    .map((m) {
                                  return DropdownMenuItem(
                                    value: m,
                                    child: Text(_toTitleCase(m.name)),
                                  );
                                }).toList(),
                                onChanged: provider.setMunicipality,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (provider.selectedMunicipality != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text('Barangay'),
                                value: provider.selectedBarangay,
                                items: provider.selectedMunicipality!.barangays
                                    .map((b) {
                                  return DropdownMenuItem(
                                    value: b,
                                    child: Text(_toTitleCase(b)),
                                  );
                                }).toList(),
                                onChanged: provider.setBarangay,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ] else ...[
                          // Global flow: State
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: provider.loadingStates
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : DropdownButton<csc.State>(
                                    isExpanded: true,
                                    hint: const Text('State'),
                                    value: provider.selectedState,
                                    items: provider.states.map((s) {
                                      return DropdownMenuItem(
                                        value: s,
                                        child: Text(_toTitleCase(s.name)),
                                      );
                                    }).toList(),
                                    onChanged: provider.setStateObj,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          if (provider.selectedState != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: provider.loadingCities
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : DropdownButton<csc.City>(
                                      isExpanded: true,
                                      hint: const Text('City'),
                                      value: provider.selectedCity,
                                      items: provider.cities.map((c) {
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Text(_toTitleCase(c.name)),
                                        );
                                      }).toList(),
                                      onChanged: provider.setCity,
                                    ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),

                // Fixed bottom section: text field + button
                Padding(
                  padding: const EdgeInsets.only(left: 32, right: 10),
                  child: TextFormField(
                    controller: _additionalInfoController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Information',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 180),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isComplete ? primary : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isComplete
                        ? () {
                            provider.inputAdditionalInfo(
                                _additionalInfoController.text);
                            logger.i(
                              'Country: ${provider.selectedCountry?.name}\n'
                              'Region: ${provider.selectedRegion?.regionName}\n'
                              'Province: ${provider.selectedProvince?.name}\n'
                              'Municipality: ${provider.selectedMunicipality?.name}\n'
                              'Barangay: ${provider.selectedBarangay}\n'
                              'State: ${provider.selectedState?.name}\n'
                              'City: ${provider.selectedCity?.name}\n'
                              'Complete Address: ${provider.completeAddress}\n'
                              'Additional Info: ${_additionalInfoController.text}',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateProfileHopeToAchievePage(),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

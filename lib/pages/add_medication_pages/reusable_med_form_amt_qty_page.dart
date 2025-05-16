import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_purpose_page_select_disease.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class ReusableMedFormAmtQtyPage extends StatefulWidget {
  const ReusableMedFormAmtQtyPage({super.key});

  @override
  _ReusableMedFormAmtQtyPage createState() => _ReusableMedFormAmtQtyPage();
}

class _ReusableMedFormAmtQtyPage extends State<ReusableMedFormAmtQtyPage> {
  String? selectedMedForm;
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final selectedMed = provider.selectedMed;

    final List<String> medFormOptions = [
      "Pill",
      "Tablet",
      "Injection",
      "Solution (Liquid)",
      "Drops",
      "Inhaler",
      "Powder",
      "Cream",
      "Ointment",
      "Spray", // Additional options
    ];

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: primaryColor,
        title: Text("Form", style: TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey, // Add form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20), // Top spacing

              // Icon (Static)
              Center(
                child: FadeIn(
                  duration: Duration(milliseconds: 500),
                  child: Icon(Icons.medical_services,
                      size: 80, color: primaryColor),
                ),
              ),

              SizedBox(height: 20),

              // Title (Static)
              Center(
                child: FadeIn(
                  delay: Duration(milliseconds: 200),
                  duration: Duration(milliseconds: 500),
                  child: Text(
                    "What form is the med\n$selectedMed?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Dropdown for Medication Form
              FadeIn(
                delay: Duration(milliseconds: 300),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      style: TextStyle(fontSize: 17, color: Colors.black),
                      value: selectedMedForm,
                      items: medFormOptions
                          .map((medForm) => DropdownMenuItem<String>(
                                value: medForm,
                                child: Text(
                                  medForm,
                                  style: TextStyle(fontSize: 17),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMedForm = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Medication Form",
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true, // Make it use full width
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a medication form';
                        }
                        return null; // Return null if no error
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Amount Field
              FadeIn(
                delay: Duration(milliseconds: 300),
                child: Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter amount (e.g. 40 mg, 10 mL)",
                          labelText: "Amount",
                          hintStyle: TextStyle(
                              color: Colors.black.withAlpha(200), fontSize: 16),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          return null; // Return null if no error
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // Display dynamic unit based on selected form, without pre-filling it
                    Text(
                      selectedMedForm != null
                          ? getUnitForAmount(selectedMedForm!)
                          : '',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Quantity Field
              FadeIn(
                delay: Duration(milliseconds: 300),
                child: Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter quantity (e.g. 1 shot, 1 pill)",
                          labelText: "Quantity",
                          hintStyle: TextStyle(
                              color: Colors.black.withAlpha(200), fontSize: 16),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantity is required';
                          }
                          return null; // Return null if no error
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // Display dynamic quantity unit based on selected form, without pre-filling it
                    Text(
                      selectedMedForm != null
                          ? getUnitForQuantity(selectedMedForm!)
                          : '',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Next Button
              SlideInUp(
                duration: Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: primaryColor),
                    onPressed: () {
                      // Only proceed if form is valid
                      if (_formKey.currentState?.validate() ?? false) {
                        // Save data and navigate to next page
                        provider.selectAmount(_amountController.text);
                        provider.selectQuantity(_quantityController.text);
                        provider.selectForm(selectedMedForm!);
                        logger.e('Medication Form: ${provider.selectedForm}');
                        logger
                            .e('Medication Amount: ${provider.selectedAmount}');
                        logger.e(
                            'Medication Quantity: ${provider.selectedQuantity}');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ReusablePurposePageSelectDisease()),
                        );
                      }
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Method to return the unit for amount
  String getUnitForAmount(String form) {
    switch (form) {
      case 'Injection':
      case 'Solution (Liquid)':
        return 'mL'; // For liquid forms
      case 'Pill':
      case 'Tablet':
        return 'g'; // For solid forms
      case 'Drops':
        return 'mL'; // For drops
      case 'Inhaler':
        return 'canister(s)'; // For inhalers
      case 'Powder':
        return 'g'; // For powder
      case 'Cream':
      case 'Ointment':
        return 'g'; // For creams and ointments
      case 'Spray':
        return 'spray(s)'; // For sprays
      default:
        return ''; // No unit
    }
  }

  // Method to return the unit for quantity
  String getUnitForQuantity(String form) {
    switch (form) {
      case 'Injection':
      case 'Solution (Liquid)':
        return 'shot(s)'; // For liquid forms
      case 'Pill':
      case 'Tablet':
        return 'pill(s)'; // For solid forms
      case 'Drops':
        return 'drop(s)'; // For drops
      case 'Inhaler':
        return 'puff(s)'; // For inhalers
      case 'Powder':
        return 'scoop(s)'; // For powder
      case 'Cream':
      case 'Ointment':
        return 'scoop(s)'; // For creams and ointments
      case 'Spray':
        return 'spray(s)'; // For sprays
      default:
        return ''; // No quantity unit
    }
  }
}

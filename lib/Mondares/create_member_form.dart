import 'package:flutter/material.dart';

class CreateMemberForm extends StatelessWidget {
  // All controllers are injected, so Lazarte manages state and collects values
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController dobController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController bmiController;
  final VoidCallback onSubmit;

  const CreateMemberForm({
    super.key,
    required this.lastNameController,
    required this.firstNameController,
    required this.dobController,
    required this.heightController,
    required this.weightController,
    required this.bmiController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.length < 2) ? "Last name required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "First name required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: "yyyy-mm-dd",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Date required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v))
                    ? 'Valid number required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v))
                    ? 'Valid number required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bmiController,
                decoration: const InputDecoration(
                  labelText: 'BMI',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v))
                    ? 'Valid number required'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    onSubmit();
                  }
                },
                child: const Text('Submit', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

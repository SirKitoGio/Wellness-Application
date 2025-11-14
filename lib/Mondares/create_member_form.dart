import 'package:flutter/material.dart';

class CreateMemberForm extends StatelessWidget {
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

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      keyboardType: keyboardType,
      validator: validator ?? (v) {
        if (v == null || v.isEmpty) return '$label required';
        return null;
      },
    );
  }

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
              buildTextFormField(
                controller: lastNameController,
                label: 'Last Name',
                validator: (v) => (v == null || v.length < 2) ? 'Last name required' : null,
              ),
              buildTextFormField(
                controller: firstNameController,
                label: 'First Name',
              ),
              buildTextFormField(
                controller: dobController,
                label: 'Date of Birth',
                hint: 'yyyy-mm-dd',
              ),
              buildTextFormField(
                controller: heightController,
                label: 'Height (cm)',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v)) ? 'Valid number required' : null,
              ),
              buildTextFormField(
                controller: weightController,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v)) ? 'Valid number required' : null,
              ),
              buildTextFormField(
                controller: bmiController,
                label: 'BMI',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v)) ? 'Valid number required' : null,
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

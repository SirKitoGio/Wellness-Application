import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CreateMemberForm());
}

class CreateMemberForm extends StatelessWidget {
  const CreateMemberForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
      ),
      home: const MemberFormPage(),
    );
  }
}

class MemberFormPage extends StatefulWidget {
  const MemberFormPage({super.key});

  @override
  State<MemberFormPage> createState() => _BuildCreateMemberForm();
}

class _BuildCreateMemberForm extends State<MemberFormPage> {
  final form = GlobalKey<FormState>();

  final TextEditingController lastname = TextEditingController();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController bmi = TextEditingController();

  @override
  void dispose() {
    lastname.dispose();
    firstname.dispose();
    dob.dispose();
    height.dispose();
    weight.dispose();
    bmi.dispose();
    super.dispose();
  }

  Future<void> createMember() async {
    String groupId = "1";
    final postData = {
      'first_name': firstname.text,
      'last_name': lastname.text,
      'dob': dob.text,
      'height': height.text,
      'weight': weight.text,
      'bmi': bmi.text,
      'group': groupId,
    };

    try {
      final response = await http.post(
        Uri.parse('https://poltergeists.online/api/create/member/$groupId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        lastname.clear();
        firstname.clear();
        dob.clear();
        height.clear();
        weight.clear();
        bmi.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member added successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Member')),
      body: Form(
        key: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: lastname,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.length < 2) ? "Last name required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: firstname,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "First name required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dob,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: "mm/dd/yyyy",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Date required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: height,
                decoration: const InputDecoration(
                  labelText: 'Height',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v))
                    ? 'Valid number required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: weight,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || !RegExp(r'^\d+(\.\d+)?$').hasMatch(v))
                    ? 'Valid number required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bmi,
                decoration: const InputDecoration(
                  labelText: 'BMI',
                  border: OutlineInputBorder(),
                ),
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
                  if (form.currentState!.validate()) {
                    createMember();
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

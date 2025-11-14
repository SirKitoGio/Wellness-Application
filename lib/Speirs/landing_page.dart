import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wellness_application/Speirs/group_page.dart';

class LandingPage extends StatefulWidget {
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String uri = 'https://poltergeists.online';

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  searchGroup() async {
    final response = await http.get(
      Uri.parse(
        '$uri/api/get/group/information?group_name=${_groupNameController.text}',
      ),
    );

    var apiData = jsonDecode(response.body);
    print('API Response: $apiData');

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupPage(
            groupData: apiData,
            groupName: _groupNameController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title For like Google
                  Text(
                    'Fitness Wellness',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      fontFamily: 'Arial',
                    ),
                  ),
                  SizedBox(height: 40),

                  // Search text field from TextBox Exercise
                  TextFormField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Search Group',
                      hintText: 'Enter your group name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter group name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Search button yun sa baba na dapat Google Search
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          searchGroup();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

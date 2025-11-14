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
  final String uri = 'https://poltergeists.online';

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> searchGroup() async {
    final query = Uri.encodeComponent(_groupNameController.text.trim());
    final url = Uri.parse('$uri/api/get/group/information?group_name=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API Error: ${response.statusCode}')),
        );
        return;
      }

      final apiData = jsonDecode(response.body);
      if (apiData is! Map || !apiData.containsKey('body')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected API response')),
        );
        return;
      }

      final groupList = apiData['body'] as List<dynamic>;
      if (groupList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No groups found')),
        );
        return;
      }

      // Search for exact match
      dynamic? foundGroup;
      for (var group in groupList) {
        if ((group['group_name'] ?? '').toString().toLowerCase() ==
            _groupNameController.text.trim().toLowerCase()) {
          foundGroup = group;
          break;
        }
      }

      if (foundGroup != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupPage(
              groupData: foundGroup,
              groupName: foundGroup['group_name'] ?? _groupNameController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
                  Text(
                    'Fitness Wellness',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      fontFamily: 'Arial',
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Search Group',
                      hintText: 'Enter your group name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter group name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
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
                      child: const Text(
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

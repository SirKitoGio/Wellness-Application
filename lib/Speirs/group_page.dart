import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Lazarte/group_members_page.dart';

class GroupPage extends StatefulWidget {
  final Map<dynamic, dynamic> groupData;
  final String groupName;

  GroupPage({required this.groupData, required this.groupName});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String uri = 'https://poltergeists.online';
  final _sectionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showCreateButton = false;

  @override
  void initState() {
    super.initState();
    checkGroupExists();
  }

  void checkGroupExists() {
    setState(() {
      showCreateButton =
          widget.groupData.isEmpty || widget.groupData['group_id'] == null;
    });
  }

  createGroup() async {
    final response = await http.post(
      Uri.parse('$uri/api/post/group/information'),
      body: {
        'group_name': widget.groupName,
        'section': _sectionController.text,
      },
    );

    if (response.statusCode == 200) {
      var apiData = jsonDecode(response.body);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GroupPage(groupData: apiData, groupName: widget.groupName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          'Group Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              if (!showCreateButton && widget.groupData['group_id'] != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupMembersPage(
                          groupId: widget.groupData['group_id'],
                          groupName: widget.groupData['group_name'],
                        ),
                      ),
                    );
                  },

                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.group, size: 60, color: Colors.blue[900]),
                          SizedBox(height: 16),
                          Text(
                            widget.groupData['group_name'] ?? widget.groupName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Section: ${widget.groupData['section'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tap to view members',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (showCreateButton)
                Column(
                  children: [
                    Text(
                      'Group not found. Create a new group.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _sectionController,
                                decoration: InputDecoration(
                                  labelText: 'Section',
                                  hintText: 'Enter section name (e.g., 204I)',
                                  prefixIcon: Icon(Icons.class_),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Section is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    createGroup();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Create Group'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

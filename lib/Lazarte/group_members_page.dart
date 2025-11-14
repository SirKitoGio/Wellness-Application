import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MemberWellnessPage extends StatelessWidget {
  final int groupId;
  final int memberId;
  final String memberName;

  const MemberWellnessPage({
    Key? key,
    required this.groupId,
    required this.memberId,
    required this.memberName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(memberName)),
      body: Center(
        child: Text(
          'Wellness Page for Member ID: $memberId\nGroup ID: $groupId',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Task 2.1
class GroupMembersPage extends StatefulWidget {
  // Task 2.2
  final int groupId;
  final String groupName;

  const GroupMembersPage({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  // Task 2.4
  List<dynamic> _members = [];
  bool _isLoading = true;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final String _apiBaseUrl = "https://poltergeists.online/api";

  @override
  void initState() {
    super.initState();
    // Task 2.5
    _getMembers();
  }

  Future<void> _getMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('$_apiBaseUrl/get/members/${widget.groupId}');
      final response = await http.get(uri);
      //Task 2.6
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> membersList = [];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          membersList = data['data'] as List;
        } else if (data is List) {
          membersList = data;
        } else {
          print("--- API DEBUG: Could not find members list in response ---");
          print("Response body: ${response.body}");
        }

        setState(() {
          _members = membersList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Failed to load members. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("An error occurred: $e");
    }
  }

  Future<void> _createMember() async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/create/member/${widget.groupId}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},

        body: json.encode({
          'group_id': widget.groupId.toString(),
          'last_name': _lastNameController.text,
          'first_name': _firstNameController.text,
          'birthday': _birthdayController.text,
          'height': _heightController.text,
          'weight': _weightController.text,
          'bmi': _bmiController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _firstNameController.clear();
        _lastNameController.clear();
        _birthdayController.clear();
        _heightController.clear();
        _weightController.clear();
        _bmiController.clear();

        Navigator.pop(context);
        _getMembers();
      } else {
        print(
          "Error creating member: ${response.statusCode}. ${response.body}",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void _showAddMemberSheet() {
    _firstNameController.clear();
    _lastNameController.clear();
    _birthdayController.clear();
    _heightController.clear();
    _weightController.clear();
    _bmiController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add New Member",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _birthdayController,
                  decoration: const InputDecoration(
                    labelText: "Birthday (YYYY-MM-DD)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: "Height (cm)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: "Weight (kg)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bmiController,
                  decoration: const InputDecoration(
                    labelText: "BMI",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createMember,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Add Member"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_members.isEmpty) {
      return const Center(
        child: Text(
          "Tap the '+' button to add one!",
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];

        final String firstName = member['first_name'];
        final String lastName = member['last_name'];
        final String fullName = '$firstName $lastName';
        final String memberId = member['member_id']?.toString() ?? '0';
        final String birthday = member['birthday'];
        final String bmi = member['bmi']?.toString() ?? 'N/A';
        final String initial = (firstName.isNotEmpty ? firstName[0] : '')
            .toUpperCase();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemberWellnessPage(
                  groupId: widget.groupId,
                  memberId: int.tryParse(memberId) ?? 0,
                  memberName: fullName,
                ),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Task 2.8
                  CircleAvatar(
                    radius: 30,
                    child: Text(initial, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task 2.9
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Birthday: $birthday",
                          style: const TextStyle(color: Colors.purple),
                        ),
                        Text(
                          "BMI: $bmi",
                          style: const TextStyle(color: Colors.purple),
                        ),
                      ],
                    ),
                  ),
                  // Task 2.15
                  const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Task 2.3
      appBar: AppBar(
        title: Text(widget.groupName), //MATT MONDARES COMPANY XD
      ),
      body: _buildContent(),
      // Task 2.12
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberSheet,
        tooltip: 'Add Member',
        child: const Icon(Icons.add),
      ),
    );
  }
}

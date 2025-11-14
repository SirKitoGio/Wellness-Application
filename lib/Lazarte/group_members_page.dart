import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Mondares/create_member_form.dart';

class GroupMembersPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupMembersPage({required this.groupId, required this.groupName});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  List<dynamic> _members = [];

  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final String _apiBaseUrl = "https://poltergeists.online/api";

  @override
  void initState() {
    super.initState();
    _getMembers();
  }

  Future<void> _getMembers() async {
    print(widget);
    try {
      final uri = Uri.parse('$_apiBaseUrl/get/members/${widget.groupId}');
      print(uri);
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _members = (data is Map && data.containsKey('body'))
              ? data['body']
              : data;
        });
      }
    } catch (e) {}
  }

  Future<void> _createMember() async {
    final postData = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'birthday': _birthdayController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'bmi': _bmiController.text,
      'group_id': widget.groupId,
    };
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/create/member/${widget.groupId}'),
        body: jsonEncode(postData),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
        },
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _lastNameController.clear();
        _firstNameController.clear();
        _birthdayController.clear();
        _heightController.clear();
        _weightController.clear();
        _bmiController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member added successfully!')),
          );
          Navigator.pop(context);
        }
        _getMembers();
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

  void _showAddMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreateMemberForm(
        lastNameController: _lastNameController,
        firstNameController: _firstNameController,
        dobController: _birthdayController,
        heightController: _heightController,
        weightController: _weightController,
        bmiController: _bmiController,
        onSubmit: _createMember,
      ),
    );
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _birthdayController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    if (_members.isEmpty)
      return const Center(
        child: Text(
          "Tap the '+' button to add one!",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
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
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(initial, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                const Icon(Icons.arrow_forward_ios, color: Colors.purple),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberSheet,
        tooltip: 'Add Member',
        child: const Icon(Icons.add),
      ),
    );
  }
}

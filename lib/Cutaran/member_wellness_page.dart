import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class MemberWellnessPage extends StatefulWidget {
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
  State<MemberWellnessPage> createState() => _MemberWellnessPageState();
}

class _MemberWellnessPageState extends State<MemberWellnessPage> {
  List<dynamic> wellnessPlans = [];
  DayOfWeek? selectedDay;
  final TextEditingController dietController = TextEditingController();
  final TextEditingController workoutController = TextEditingController();
  final TextEditingController tipsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getWellnessPlans();
  }

  Future<void> getWellnessPlans() async {
    final url =
        'https://poltergeists.online/api/get/wellness/${widget.groupId}/${widget.memberId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          wellnessPlans = jsonDecode(response.body);
        });
      }
    } catch (e) {}
  }

  Future<void> createWellnessPlan() async {
    final postData = {
      'group_id': widget.groupId,
      'member_id': widget.memberId,
      'day_of_week': selectedDay?.name ?? "",
      'diet_plan': dietController.text,
      'work_plan': workoutController.text,
      'tips': tipsController.text,
    };
    final url = 'https://poltergeists.online/api/create/wellness';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 4.33/4.34: Reset form fields
        setState(() {
          selectedDay = null;
        });
        dietController.clear();
        workoutController.clear();
        tipsController.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Wellness plan created!')));
        getWellnessPlans();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    dietController.dispose();
    workoutController.dispose();
    tipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.memberName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Existing Plans",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ...wellnessPlans.map((plan) {
              return Card(
                color: Colors.blue[50],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Day: ${plan['day_of_week']}",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Diet: ${plan['diet_plan']}"),
                      Text("Workout: ${plan['work_plan']}"),
                      Text("Tips: ${plan['tips']}"),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            const Text(
              "Create New Plan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<DayOfWeek>(
                    decoration: const InputDecoration(
                      labelText: "Day of Week",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDay,
                    items: DayOfWeek.values
                        .map(
                          (day) => DropdownMenuItem(
                            value: day,
                            child: Text(
                              day.name[0].toUpperCase() + day.name.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (day) => setState(() => selectedDay = day),
                    validator: (value) => value == null
                        ? "Please select a day of the week"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dietController,
                    decoration: const InputDecoration(
                      labelText: "Diet Plan",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Diet plan required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: workoutController,
                    decoration: const InputDecoration(
                      labelText: "Workout Plan",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Workout plan required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tipsController,
                    decoration: const InputDecoration(
                      labelText: "Tips",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Tips required" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Submit Plan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          selectedDay != null) {
                        createWellnessPlan();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please complete all fields!"),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

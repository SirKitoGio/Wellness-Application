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

extension DayOfWeekExtension on DayOfWeek {
    String get nameLower {return toString().split('.').last;}
    String get displayName {final n = nameLower;return n[0].toUpperCase() + n.substring(1);}
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
    final String _apiBaseUrl = "https://poltergeists.online/api";
    List<dynamic> wellnessPlans = [];
    DayOfWeek? selectedDay;
    final TextEditingController dietCtrlr = TextEditingController();
    final TextEditingController workoutCtrlr = TextEditingController();
    final TextEditingController tipsCtrlr = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool _isLoadingPlans = true;
    @override
    void initState() {super.initState();getWellnessPlans();}
    Future<void> getWellnessPlans() async {
        setState(() {_isLoadingPlans = true;});
        try {
            final uri = Uri.parse('$_apiBaseUrl/get/wellness/${widget.groupId}/${widget.memberId}');
            final response = await http.get(uri);
            if (response.statusCode == 200) {
                final decoded = jsonDecode(response.body);
                final plans = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
                if (mounted) setState(() {wellnessPlans = (plans is List) ? plans : []; _isLoadingPlans = false;});
            }
            else
            if (mounted) {
                setState(() {wellnessPlans = [];_isLoadingPlans = false;});
                showSnackBar(context,'Failed to load plans: ','${response.statusCode} ${response.reasonPhrase}',);
            }
        } catch (e) {
            if (mounted) {
                setState(() {wellnessPlans = [];_isLoadingPlans = false;});
                showSnackBar(context,'Error: ', e.toString());
            }
        }
    }
    Future<void> createWellnessPlan() async {
        if (!_formKey.currentState!.validate() || selectedDay == null) {
            if (mounted) showSnackBar(context, '', 'Please fill all required fields.');
            return;
        }
        final body = {
            'group_id': widget.groupId.toString(),
            'member_id': widget.memberId.toString(),
            'day_of_week': selectedDay!.nameLower,
            'diet': dietCtrlr.text.trim(),
            'workout': workoutCtrlr.text.trim(),
            'tips': tipsCtrlr.text.trim(),
        };
        try {
            final uri = Uri.parse('$_apiBaseUrl/create/wellness');
            final response = await http.post(uri,headers: {'Content-Type': 'application/json'},body: jsonEncode(body),);
            if (response.statusCode == 200 || response.statusCode == 201) {
                dietCtrlr.clear();
                workoutCtrlr.clear();
                tipsCtrlr.clear();
            if (mounted) {
                    setState(() {selectedDay = null;});
                    showSnackBar(context, '', 'Wellness plan created.');
                }
                await getWellnessPlans();
            } else {
                if (mounted) showSnackBar(context, 'Failed: ', response.body);
            }
        }
        catch (e) {
            if (mounted) showSnackBar(context, 'Error: ', e.toString());
        }
    }
    void showSnackBar(BuildContext context, String prefix, String message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$prefix$message')),);
    }
    Widget _buildExistingPlansSection() {
        if (_isLoadingPlans) return const Center(child: CircularProgressIndicator());
        if (wellnessPlans.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 16.0),child: Text('No existing plans.'),);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: wellnessPlans.map((plan) {
                final day =plan['day_of_week'] ?? plan['day'] ?? plan['dayOfWeek'] ?? 'N/A';
                final diet = plan['diet'] ?? plan['diet_plan'] ?? 'N/A';
                final workout = plan['workout'] ?? plan['work_plan'] ?? 'N/A';
                final tips = plan['tips'] ?? plan['note'] ?? 'N/A';
                return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                day is String ? (day[0].toUpperCase() + day.substring(1)) : '$day',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                buildInfoRow('Diet', diet?.toString()),
                                buildInfoRow('Workout', workout?.toString()),
                                buildInfoRow('Tips', tips?.toString()),
                            ],
                        ),
                    ),
                );
            }).toList(),
        );
    }
    Widget buildInfoRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();
        return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                        TextSpan(text: '$label: ',style: const TextStyle(fontWeight: FontWeight.w600),),
                        TextSpan(text: value),
                    ],
                ),
            ),
        );
    }
    Widget buildTextArea({required TextEditingController controller,required String label}) {
        return TextFormField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? "$label is required" : null,
        );
    }
    Widget _buildCreatePlanForm() {
        return Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const SizedBox(height: 12),
                    const Text('Create New Plan',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DayOfWeek>(
                        value: selectedDay,
                        items: DayOfWeek.values.map((d) => DropdownMenuItem<DayOfWeek>(value: d,child: Text(d.displayName),),).toList(),
                        onChanged: (v) {setState(() {selectedDay = v;});},
                        validator: (v) => v == null ? 'Please select a day' : null,
                        decoration: const InputDecoration(labelText: 'Day',border: OutlineInputBorder(),),
                    ),
                    const SizedBox(height: 12),
                    buildTextArea(controller: dietCtrlr,label: "Diet Plan",),
                    const SizedBox(height: 12),
                    buildTextArea(controller: workoutCtrlr,label: "Workout Plan",),
                    const SizedBox(height: 12),
                    buildTextArea(controller: tipsCtrlr,label: "Tips",),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('Submit', style: TextStyle(fontSize: 16)),
                            ),
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                                if (!_formKey.currentState!.validate() || selectedDay == null) {
                                    showSnackBar(context, '', 'Please complete required fields');
                                    return;
                                }
                                await createWellnessPlan();
                            },
                        ),
                    ),
                ],
            ),
        );
    }

    @override
    void dispose() {
        dietCtrlr.dispose();
        workoutCtrlr.dispose();
        tipsCtrlr.dispose();
        super.dispose();
    }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text(widget.memberName),),
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text('Existing Plans',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 8),
                            _buildExistingPlansSection(),
                            const SizedBox(height: 20),
                            _buildCreatePlanForm(),
                        ],
                    ),
                ),
            ),
        );
    }
}

import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';

class ApplicantsScreen extends StatefulWidget {
  final String jobId;

  const ApplicantsScreen({super.key, required this.jobId});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final ApplicationService _service = ApplicationService();

  List<Application> apps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final data = await _service.getApplicationsByJob(widget.jobId);

    setState(() {
      apps = data;
      isLoading = false;
    });
  }

  void update(String id, String status) async {
    await _service.updateStatus(id, status);
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ผู้สมัคร')),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (_, i) {
          final app = apps[i];

          return ListTile(
            title: Text('Student ID: ${app.studentId}'),
            subtitle: Text('Status: ${app.status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => update(app.id, 'accepted'),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => update(app.id, 'rejected'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
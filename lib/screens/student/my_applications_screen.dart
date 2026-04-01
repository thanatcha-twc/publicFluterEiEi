import 'package:flutter/material.dart';
import '../../services/application_service.dart';

class MyApplicationsScreen extends StatefulWidget {
  final String studentId;

  const MyApplicationsScreen({super.key, required this.studentId});

  @override
  State<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final ApplicationService _service = ApplicationService();

  List<Map<String, dynamic>> apps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final data = await _service.getMyApplications(widget.studentId);

    setState(() {
      apps = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('งานที่สมัคร')),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (_, i) {
          final job = apps[i]['jobs'];
          final status = apps[i]['status'];

          return ListTile(
            title: Text(job['title']),
            subtitle: Text('สถานะ: $status'),
          );
        },
      ),
    );
  }
}
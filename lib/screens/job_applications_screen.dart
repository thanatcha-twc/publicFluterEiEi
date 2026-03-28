import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/models/job_post.dart';
import 'package:quick_jobs/providers/job_provider.dart';

class JobApplicationsScreen extends StatefulWidget {
  final JobPost job;

  const JobApplicationsScreen({super.key, required this.job});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.loadApplicationsForJob(widget.job.id);
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Applications for ${widget.job.title}'),
        backgroundColor: const Color(0xFF2B2EC7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: jobProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: jobProvider.applications.length,
                itemBuilder: (context, index) {
                  final application = jobProvider.applications[index];
                  // Assuming applications include user data via join
                  final studentName =
                      'Student ${application.studentId}'; // Replace with actual name if joined
                  return Card(
                    child: ListTile(
                      title: Text(studentName),
                      subtitle: Text('Status: ${application.status}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (status) {
                          jobProvider.updateApplicationStatus(
                            application.id,
                            status,
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          const PopupMenuItem(
                            value: 'accepted',
                            child: Text('Accepted'),
                          ),
                          const PopupMenuItem(
                            value: 'rejected',
                            child: Text('Rejected'),
                          ),
                          const PopupMenuItem(
                            value: 'completed',
                            child: Text('Completed'),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to student profile
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/providers/job_provider.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.loadApplicationsForStudent(authProvider.user!.id);
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
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
                  final job = jobProvider.jobPosts.firstWhere(
                    (j) => j.id == application.jobPostId,
                  );
                  return Card(
                    child: ListTile(
                      title: Text(job.title),
                      subtitle: Text('Status: ${application.status}'),
                      trailing: Text(
                        application.appliedAt.toString().split(' ')[0],
                      ),
                      onTap: () {
                        // Navigate to job details
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

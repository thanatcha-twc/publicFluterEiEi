import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/providers/job_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    // Calculate completed jobs and credits
    final completedApplications = jobProvider.applications
        .where(
          (app) =>
              app.status == 'completed' &&
              app.studentId == authProvider.user!.id,
        )
        .toList();
    final totalCredits = completedApplications
        .map(
          (app) =>
              jobProvider.jobPosts
                  .firstWhere((job) => job.id == app.jobPostId)
                  .credits ??
              0,
        )
        .fold(0.0, (sum, credits) => sum + credits);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2B2EC7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authProvider.user?.name ?? 'Student',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${authProvider.user?.email ?? ''}'),
            Text('Faculty: ${authProvider.user?.faculty ?? ''}'),
            Text('Department: ${authProvider.user?.department ?? ''}'),
            const SizedBox(height: 20),
            Text(
              'Total Credits: $totalCredits',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text(
              'Completed Jobs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: completedApplications.length,
                itemBuilder: (context, index) {
                  final application = completedApplications[index];
                  final job = jobProvider.jobPosts.firstWhere(
                    (j) => j.id == application.jobPostId,
                  );
                  return ListTile(
                    title: Text(job.title),
                    subtitle: Text('Credits: ${job.credits ?? 0}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/providers/job_provider.dart';
import 'package:quick_jobs/widgets/job_card.dart';
import 'package:quick_jobs/screens/create_edit_job_screen.dart';
import 'package:quick_jobs/screens/role_selection_screen.dart';
import 'package:quick_jobs/screens/job_detail_screen.dart';

class ProfessorFeedScreen extends StatefulWidget {
  const ProfessorFeedScreen({super.key});

  @override
  State<ProfessorFeedScreen> createState() => _ProfessorFeedScreenState();
}

class _ProfessorFeedScreenState extends State<ProfessorFeedScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    if (authProvider.isProfessor) {
      jobProvider.loadJobPosts(professorId: authProvider.user!.id);
    }
  }

  void _deleteJob(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<JobProvider>(
                context,
                listen: false,
              ).deleteJobPost(jobId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    if (!authProvider.isProfessor) {
      return const Scaffold(
        body: Center(child: Text('Access denied. Professor only.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor Feed'),
        backgroundColor: const Color(0xFF2B2EC7),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEditJobScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${authProvider.user?.name ?? 'Professor'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${authProvider.user?.email ?? ''}'),
            const SizedBox(height: 20),
            const Text(
              'Your Posted Jobs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: jobProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: jobProvider.jobPosts.length,
                      itemBuilder: (context, index) {
                        final job = jobProvider.jobPosts[index];
                        return JobCard(
                          job: job,
                          isProfessor: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(
                                  job: job,
                                  isProfessor: true,
                                ),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CreateEditJobScreen(jobToEdit: job),
                              ),
                            );
                          },
                          onDelete: () => _deleteJob(context, job.id),
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

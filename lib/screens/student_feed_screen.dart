import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/providers/job_provider.dart';
import 'package:quick_jobs/widgets/job_card.dart';
import 'package:quick_jobs/screens/student_profile_screen.dart';
import 'package:quick_jobs/screens/applied_jobs_screen.dart';
import 'package:quick_jobs/screens/role_selection_screen.dart';
import 'package:quick_jobs/models/job_post.dart';

class StudentFeedScreen extends StatefulWidget {
  const StudentFeedScreen({super.key});

  @override
  State<StudentFeedScreen> createState() => _StudentFeedScreenState();
}

class _StudentFeedScreenState extends State<StudentFeedScreen> {
  final _searchController = TextEditingController();
  List<JobPost> _filteredJobs = [];
  Map<String, bool> _appliedJobs = {}; // jobId -> hasApplied

  @override
  void initState() {
    super.initState();
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.loadJobPosts();
    _filteredJobs = jobProvider.jobPosts;
    _loadAppliedStatus();
  }

  Future<void> _loadAppliedStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.user != null) {
      final applications = await jobProvider.getApplicationsForStudent(
        authProvider.user!.id,
      );
      setState(() {
        _appliedJobs = {for (var app in applications) app.jobPostId: true};
      });
    }
  }

  void _filterJobs(String query) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _filteredJobs = jobProvider.jobPosts
            .where((job) => job.status == 'open')
            .toList();
      });
    } else {
      final results = await jobProvider.searchJobPosts(query);
      setState(() {
        _filteredJobs = results;
      });
    }
  }

  void _onJobApplied(String jobId) {
    setState(() {
      _appliedJobs[jobId] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    if (!authProvider.isStudent) {
      return const Scaffold(
        body: Center(child: Text('Access denied. Student only.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2B2EC7),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user?.name ?? 'Student',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user?.id ?? 'Unknown ID',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person, color: Color(0xFF2B2EC7)),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppliedJobsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFF2B2EC7),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Color(0xFF2B2EC7)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Find your',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
              ),
              const Text(
                'Creative job!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2EC7),
                ),
              ),
              const SizedBox(height: 20),
              // Search
              TextField(
                controller: _searchController,
                onChanged: _filterJobs,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2B2EC7),
                  ),
                  hintText: 'Search job',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2B2EC7)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Section 1
              const Text(
                'งานที่คุณอาจสนใจ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: jobProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          return JobCard(
                            job: job,
                            hasApplied: _appliedJobs[job.id] ?? false,
                            onApply: () {
                              jobProvider
                                  .applyForJob(authProvider.user!.id, job.id)
                                  .then((_) {
                                    _onJobApplied(job.id);
                                  });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

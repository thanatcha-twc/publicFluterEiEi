import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/models/job_post.dart';
import 'package:quick_jobs/models/application.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/providers/job_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final JobPost job;
  final bool isProfessor;

  const JobDetailScreen({
    super.key,
    required this.job,
    required this.isProfessor,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  List<Application> _applications = [];
  bool _isLoading = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    if (widget.isProfessor) {
      _loadApplications();
    } else {
      _checkApplicationStatus();
    }
  }

  Future<void> _checkApplicationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.user != null) {
      final hasApplied = await jobProvider.hasUserAppliedForJob(
        authProvider.user!.id,
        widget.job.id,
      );
      setState(() => _hasApplied = hasApplied);
    }
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final applications = await jobProvider.getApplicationsForJob(
        widget.job.id,
      );
      setState(() => _applications = applications);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading applications: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyForJob() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    try {
      await jobProvider.applyForJob(authProvider.user!.id, widget.job.id);
      setState(() => _hasApplied = true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('สมัครสำเร็จ!')));

      // Go back to student feed
      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // Pass true to indicate application was made
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  Future<void> _updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.updateApplicationStatus(applicationId, status);

      // Refresh applications list
      await _loadApplications();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Application ${status == 'accepted' ? 'accepted' : 'rejected'}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating application: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.title),
        backgroundColor: const Color(0xFF2B2EC7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (widget.job.requirements != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Requirements:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.job.requirements!),
                    ],
                    if (widget.job.credits != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Credits: ${widget.job.credits}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2EC7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Status: ${widget.job.status}',
                      style: TextStyle(
                        color: widget.job.status == 'open'
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button for Students
            if (!widget.isProfessor) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasApplied ? null : _applyForJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasApplied
                        ? Colors.grey
                        : const Color(0xFF2B2EC7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _hasApplied ? 'สมัครแล้ว' : 'สมัครงานนี้',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],

            // Applications List for Professors
            if (widget.isProfessor) ...[
              const SizedBox(height: 20),
              const Text(
                'ผู้สมัครงาน:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_applications.isEmpty)
                const Text('ยังไม่มีผู้สมัคร')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final application = _applications[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        application.studentId,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Applied: ${application.appliedAt.toString().split(' ')[0]}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: application.status == 'pending'
                                        ? Colors.orange
                                        : application.status == 'accepted'
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    application.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (application.status == 'pending') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateApplicationStatus(
                                        application.id,
                                        'accepted',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('ถูกเลือก'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateApplicationStatus(
                                        application.id,
                                        'rejected',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('ไม่ถูกเลือก'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

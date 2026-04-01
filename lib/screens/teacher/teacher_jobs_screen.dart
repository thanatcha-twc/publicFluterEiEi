import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import 'applicants_screen.dart';

class TeacherJobsScreen extends StatefulWidget {
  final String teacherId;

  const TeacherJobsScreen({super.key, required this.teacherId});

  @override
  State<TeacherJobsScreen> createState() => _TeacherJobsScreenState();
}

class _TeacherJobsScreenState extends State<TeacherJobsScreen> {
  final JobService _jobService = JobService();

  List<Job> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      final result =
          await _jobService.getJobsByTeacher(widget.teacherId);

      if (!mounted) return;

      setState(() {
        jobs = result;
        isLoading = false;
      });
    } catch (e) {
      print('ERROR: $e');
    }
  }

  void deleteJob(String jobId) async {
    await _jobService.deleteJob(jobId);
    fetchJobs();
  }

  void showCreateDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final salaryController = TextEditingController();
    final maxController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('สร้างงาน'),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'ชื่องาน'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ค่าจ้าง'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'จำนวนรับ'),
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),

          TextButton(
            onPressed: () async {
              final salary =
                  int.tryParse(salaryController.text.trim()) ?? 0;
              final max =
                  int.tryParse(maxController.text.trim()) ?? 1;

              await _jobService.createJob(
                title: titleController.text.trim(),
                description: descController.text.trim(),
                salary: salary,
                maxApplicants: max,
                teacherId: widget.teacherId,
              );

              if (!mounted) return;

              Navigator.pop(context);
              fetchJobs();
            },
            child: const Text('สร้าง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('งานของฉัน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showCreateDialog,
          ),
        ],
      ),

      body: jobs.isEmpty
          ? const Center(child: Text('ยังไม่มีงาน'))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (_, index) {
                final job = jobs[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(job.title),
                    subtitle: Text(job.description),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ApplicantsScreen(jobId: job.id),
                        ),
                      );
                    },

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteJob(job.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
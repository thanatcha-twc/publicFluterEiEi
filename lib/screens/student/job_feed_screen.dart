import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/application_service.dart';
import 'profile_screen.dart';
import 'my_applications_screen.dart';

class JobFeedScreen extends StatefulWidget {
  final String studentId;

  const JobFeedScreen({super.key, required this.studentId});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final JobService _jobService = JobService();
  final ApplicationService _applicationService = ApplicationService();

  List<Job> jobs = [];
  List<Map<String, dynamic>> rawJobs = [];

  bool isLoading = true;

  Map<String, bool> appliedMap = {};
  String searchText = '';

  String studentName = '';
  String studentCode = '';

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchJobs();
  }

  /// 👤 USER
  Future<void> fetchUser() async {
    final data = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', widget.studentId)
        .single();

    if (!mounted) return;

    setState(() {
      studentName = data['username'] ?? '';
      studentCode = data['student_code'] ?? '';
    });
  }

  /// 🔥 JOB + JOIN
  Future<void> fetchJobs() async {
    final result = await _jobService.getJobsWithTeacher();

    Map<String, bool> temp = {};

    for (var job in result) {
      final applied = await _applicationService.hasApplied(
        job['id'],
        widget.studentId,
      );

      temp[job['id']] = applied;
    }

    if (!mounted) return;

    setState(() {
      rawJobs = result;
      jobs = result.map((e) => Job.fromJson(e)).toList();
      appliedMap = temp;
      isLoading = false;
    });
  }

  Future<void> apply(Job job) async {
    final success = await _applicationService.applyJob(
      jobId: job.id,
      studentId: widget.studentId,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        appliedMap[job.id] = true;
      });
    }
  }

  /// 🔝 HEADER FIX (ไม่ล้น + โปร)
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10), // 🔥 ลดด้านบน
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 TOP BAR
          Row(
            children: [
              /// PROFILE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfileScreen(studentId: widget.studentId),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Image.asset(
                        'assets/icons/graduate.png',
                        width: 16,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(), // 🔥 กันพัง
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              /// NAME
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      studentCode,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔔 NOTIFICATION
              IconButton(
                icon: Image.asset(
                  'assets/icons/bell.png',
                  width: 22,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.notifications),
                ),
                onPressed: () {},
              ),

              /// 💼 WORK
              IconButton(
                icon: Image.asset(
                  'assets/icons/work.png',
                  width: 22,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.work),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyApplicationsScreen(
                        studentId: widget.studentId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔥 TITLE
          const Text(
            'Find your\nCreative job!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          /// 🔍 SEARCH
          TextField(
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
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

    final filteredIndexes = List.generate(rawJobs.length, (i) => i)
        .where((i) => jobs[i]
            .title
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: SafeArea( // 🔥 สำคัญมาก
        child: Column(
          children: [
            _header(),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 10),
                itemCount: filteredIndexes.length,
                itemBuilder: (context, index) {
                  final i = filteredIndexes[index];
                  final job = jobs[i];
                  final raw = rawJobs[i];

                  final isApplied = appliedMap[job.id] ?? false;

                  final teacherName =
                      raw['users']?['full_name'] ?? 'Unknown';

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        )
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 👨‍🏫 TEACHER
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              child: Icon(Icons.person, size: 14),
                            ),
                            const SizedBox(width: 6),

                            Expanded(
                              child: Text(
                                'อาจารย์ $teacherName',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            Image.asset(
                              'assets/icons/verify.png',
                              width: 14,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// TITLE
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B2EC7),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          job.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '฿ ${job.salary}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            ElevatedButton(
                              onPressed:
                                  isApplied ? null : () => apply(job),
                              child: Text(
                                isApplied ? 'สมัครแล้ว' : 'สมัคร',
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
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
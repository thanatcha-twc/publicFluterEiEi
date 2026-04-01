import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String studentId;

  const ProfileScreen({super.key, required this.studentId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String studentCode = '';

  int totalApplied = 0;
  int totalAccepted = 0;

  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchStats();
    fetchHistory();
  }

  Future<void> fetchUser() async {
    final data = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', widget.studentId)
        .single();

    setState(() {
      name = data['username'] ?? '';
      studentCode = data['student_code'] ?? '';
    });
  }

  Future<void> fetchStats() async {
    final applied = await Supabase.instance.client
        .from('applications')
        .select()
        .eq('student_id', widget.studentId);

    final accepted = applied.where((e) => e['status'] == 'accepted');

    setState(() {
      totalApplied = applied.length;
      totalAccepted = accepted.length;
    });
  }

  Future<void> fetchHistory() async {
    final data = await Supabase.instance.client
        .from('applications')
        .select('*, jobs(*)')
        .eq('student_id', widget.studentId)
        .eq('status', 'accepted');

    setState(() {
      history = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// 🔥 PROFILE HEADER
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      AssetImage('assets/images/profile.png'),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Image.asset(
                    'assets/icons/graduate.png',
                    width: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              studentCode,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// 🔥 STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statBox('สมัคร', totalApplied),
                _statBox('ได้งาน', totalAccepted),
                _statBox('เครดิต', totalAccepted * 10),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 HISTORY
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ผลงานของฉัน',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            ...history.map((e) {
              final job = e['jobs'];

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(job['description']),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title),
      ],
    );
  }
}
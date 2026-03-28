import 'package:flutter/material.dart';
import 'package:quick_jobs/models/auth_response.dart';
import 'package:quick_jobs/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthResponse user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ออกจากระบบ'),
                  content: const Text('คุณแน่ใจว่าต้องการออกจากระบบ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('ออกจากระบบ'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลผู้ใช้',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('ชื่อ-สกุล', user.name ?? '-'),
                    _buildInfoRow('username', user.username ?? '-'),
                    _buildInfoRow('รหัสประชาชน', user.cid ?? '-'),
                    _buildInfoRow('ประเภท', user.type ?? '-'),
                    _buildInfoRow('คณะ', user.facname ?? '-'),
                    _buildInfoRow('แผนก', user.depname ?? '-'),
                    _buildInfoRow('สาขา', user.secname ?? '-'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
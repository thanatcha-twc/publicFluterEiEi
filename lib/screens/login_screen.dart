import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'teacher/teacher_jobs_screen.dart';
import '../screens/student/job_feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;
  String error = '';
  bool _obscurePassword = true;

  final Color primary = const Color(0xFF2B2EC7);

  Future<void> _login() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        error = 'กรุณากรอกข้อมูลให้ครบ';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      error = '';
    });

    final user = await _authService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (user == null) {
      setState(() {
        error = 'Login ไม่สำเร็จ';
      });
      return;
    }

    // 🔥 routing เดิม (ไม่แตะ logic)
    if (user.role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => JobFeedScreen(studentId: user.id)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TeacherJobsScreen(teacherId: user.id),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCFCFCF), letterSpacing: 1),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔥 LOGO
                      SizedBox(
                        width: 200,
                        height: 110,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Username
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'e-Passport',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      TextField(
                        controller: _usernameController,
                        enabled: !isLoading,
                        decoration: _inputDecoration('e-Passport'),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Password
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      TextField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          '••••••••',
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔥 ERROR
                      if (error.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            error,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // 🔥 BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

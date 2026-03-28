import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/screens/professor_feed_screen.dart';
import 'package:quick_jobs/screens/student_feed_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? role;

  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _errorMessage = '';

  final Color primary = const Color(0xFF2B2EC7);

  Future<void> _login() async {
    final role = widget.role;
    if (role == null || role.isEmpty) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: ระบุบทบาทก่อนเข้าสู่ระบบ';
      });
      return;
    }

    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอก Username และ Password ให้ครบถ้วน';
      });
      return;
    }

    // Additional validation for professor role
    if (role.toLowerCase() == 'professor') {
      if (_usernameController.text.trim().toLowerCase() != 'professor') {
        setState(() {
          _errorMessage = 'Username สำหรับอาจารย์ต้องเป็น "professor"';
        });
        return;
      }
      if (_passwordController.text != '123456') {
        setState(() {
          _errorMessage = 'Password สำหรับอาจารย์ต้องเป็น "123456"';
        });
        return;
      }
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = '';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
      role,
    );

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      if (authProvider.isProfessor) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfessorFeedScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentFeedScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage.isNotEmpty
            ? authProvider.errorMessage
            : 'เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบข้อมูล';
      });
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFFCFCFCF), letterSpacing: 2),
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
                      SizedBox(
                        width: 200,
                        height: 110,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'e-Passport',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      TextField(
                        controller: _usernameController,
                        enabled: !Provider.of<AuthProvider>(context).isLoading,
                        decoration: _inputDecoration('e-Passport'),
                      ),

                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      TextField(
                        controller: _passwordController,
                        enabled: !Provider.of<AuthProvider>(context).isLoading,
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

                      const SizedBox(height: 32),

                      if (_errorMessage.isNotEmpty)
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
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              Provider.of<AuthProvider>(context).isLoading
                              ? null
                              : () async => await _login(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Provider.of<AuthProvider>(context).isLoading
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

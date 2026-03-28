import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/screens/login_screen.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/providers/job_provider.dart';
import 'package:quick_jobs/screens/professor_feed_screen.dart';
import 'package:quick_jobs/screens/student_feed_screen.dart';
import 'package:quick_jobs/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: MaterialApp(
        title: 'Quick Jobs',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              // ดึง role จาก user
              final role = authProvider.user?.role;
              if (role == 'professor') {
                return const ProfessorFeedScreen();
              } else if (role == 'student') {
                return const StudentFeedScreen();
              } else {
                return const Scaffold(
                  body: Center(child: Text('Unknown role')),
                );
              }
            }
            // ถ้ายังไม่ login
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

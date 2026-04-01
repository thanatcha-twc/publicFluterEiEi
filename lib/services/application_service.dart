import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart'; // ✅ ต้องมีอันนี้

class ApplicationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> applyJob({
    required String jobId,
    required String studentId,
  }) async {
    try {
      await _supabase.from('applications').insert({
        'job_id': jobId,
        'student_id': studentId,
      });

      return true;
    } catch (e) {
      print('Apply error: $e');
      return false;
    }
  }

  Future<List<Application>> getApplicationsByJob(String jobId) async {
    final data = await _supabase
        .from('applications')
        .select()
        .eq('job_id', jobId);

    return (data as List).map((e) => Application.fromJson(e)).toList();
  }

  Future<void> updateStatus(String applicationId, String status) async {
    await _supabase
        .from('applications')
        .update({'status': status})
        .eq('id', applicationId);
  }

  Future<List<Map<String, dynamic>>> getAcceptedJobs(String studentId) async {
    final data = await _supabase
        .from('applications')
        .select('*, jobs(*)')
        .eq('student_id', studentId)
        .eq('status', 'accepted');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<bool> hasApplied(String jobId, String studentId) async {
    final data = await _supabase
        .from('applications')
        .select()
        .eq('job_id', jobId)
        .eq('student_id', studentId);

    return data.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getMyApplications(String studentId) async {
    final data = await _supabase
        .from('applications')
        .select('*, jobs(*)')
        .eq('student_id', studentId);

    return List<Map<String, dynamic>>.from(data);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';

class JobService {
  final supabase = Supabase.instance.client;

  /// ✅ FIX JOIN (ไม่ใช้ชื่อ FK แล้ว)
  Future<List<Map<String, dynamic>>> getJobsWithTeacher() async {
    try {
      final data = await supabase
          .from('jobs')
          .select('*, users(id, full_name)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('ERROR getJobsWithTeacher: $e');
      return [];
    }
  }

  /// ✅ FIX METHOD ERROR
  Future<List<Job>> getJobsByTeacher(String teacherId) async {
    try {
      final data = await supabase
          .from('jobs')
          .select()
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => Job.fromJson(e)).toList();
    } catch (e) {
      print('ERROR getJobsByTeacher: $e');
      return [];
    }
  }

  Future<void> createJob({
    required String title,
    required String description,
    required int salary,
    required int maxApplicants,
    required String teacherId,
  }) async {
    await supabase.from('jobs').insert({
      'title': title,
      'description': description,
      'salary': salary,
      'max_applicants': maxApplicants,
      'teacher_id': teacherId,
    });
  }

  Future<void> deleteJob(String jobId) async {
    await supabase.from('jobs').delete().eq('id', jobId);
  }
}
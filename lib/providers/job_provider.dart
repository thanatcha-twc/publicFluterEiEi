import 'package:flutter/material.dart';
import 'package:quick_jobs/models/job_post.dart';
import 'package:quick_jobs/models/application.dart';
import 'package:quick_jobs/services/supabase_service.dart';

class JobProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<JobPost> _jobPosts = [];
  List<Application> _applications = [];
  bool _isLoading = false;

  List<JobPost> get jobPosts => _jobPosts;
  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;

  Future<void> loadJobPosts({String? professorId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobPosts = await _supabaseService.getJobPosts(professorId: professorId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createJobPost(JobPost jobPost) async {
    try {
      final newJobPost = await _supabaseService.createJobPost(jobPost);
      _jobPosts.insert(0, newJobPost);
      notifyListeners();
    } catch (e) {
      print('[JobProvider] createJobPost error: $e');
      rethrow;
    }
  }

  Future<void> updateJobPost(String id, Map<String, dynamic> updates) async {
    try {
      await _supabaseService.updateJobPost(id, updates);
      final index = _jobPosts.indexWhere((job) => job.id == id);
      if (index != -1) {
        _jobPosts[index] = JobPost.fromJson({
          ..._jobPosts[index].toJson(),
          ...updates,
        });
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteJobPost(String id) async {
    try {
      await _supabaseService.deleteJobPost(id);
      _jobPosts.removeWhere((job) => job.id == id);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadApplicationsForJob(String jobPostId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _applications = await _supabaseService.getApplicationsForJob(jobPostId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadApplicationsForStudent(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _applications = await _supabaseService.getApplicationsForStudent(
        studentId,
      );
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForJob(String studentId, String jobPostId) async {
    try {
      final application = await _supabaseService.applyForJob(
        studentId,
        jobPostId,
      );
      _applications.insert(0, application);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    try {
      await _supabaseService.updateApplicationStatus(id, status);
      final index = _applications.indexWhere((app) => app.id == id);
      if (index != -1) {
        _applications[index] = Application.fromJson({
          ..._applications[index].toJson(),
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        });
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<List<Application>> getApplicationsForJob(String jobPostId) async {
    try {
      return await _supabaseService.getApplicationsForJob(jobPostId);
    } catch (e) {
      return [];
    }
  }

  Future<List<Application>> getApplicationsForStudent(String studentId) async {
    try {
      return await _supabaseService.getApplicationsForStudent(studentId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> hasUserAppliedForJob(String studentId, String jobPostId) async {
    try {
      final applications = await _supabaseService.getApplicationsForStudent(
        studentId,
      );
      return applications.any((app) => app.jobPostId == jobPostId);
    } catch (e) {
      return false;
    }
  }

  Future<List<JobPost>> searchJobPosts(String query) async {
    try {
      return await _supabaseService.searchJobPosts(query);
    } catch (e) {
      return [];
    }
  }
}

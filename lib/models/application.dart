class Application {
  final String id;
  final String studentId;
  final String jobPostId;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? notes;

  Application({
    required this.id,
    required this.studentId,
    required this.jobPostId,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.notes,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      studentId: json['student_id'],
      jobPostId: json['job_post_id'],
      status: json['status'],
      appliedAt: DateTime.parse(json['applied_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'job_post_id': jobPostId,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

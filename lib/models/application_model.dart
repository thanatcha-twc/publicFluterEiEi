class Application {
  final String id;
  final String jobId;
  final String studentId;
  final String status;

  Application({
    required this.id,
    required this.jobId,
    required this.studentId,
    required this.status,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      jobId: json['job_id'],
      studentId: json['student_id'],
      status: json['status'],
    );
  }
}
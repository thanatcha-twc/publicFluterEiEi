class Job {
  final String id;
  final String title;
  final String description;
  final int salary;
  final int maxApplicants;
  final String teacherId;

  /// 🔥 เพิ่มตัวนี้
  final String teacherName;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.salary,
    required this.maxApplicants,
    required this.teacherId,
    required this.teacherName,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      salary: json['salary'],
      maxApplicants: json['max_applicants'],
      teacherId: json['teacher_id'],

      /// 🔥 JOIN จาก users
      teacherName: json['users']?['full_name'] ?? 'Unknown',
    );
  }
}
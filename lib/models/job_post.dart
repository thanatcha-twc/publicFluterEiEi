class JobPost {
  final String id;
  final String professorId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;

  final String? professorName;
  final String? requirements;
  final double? credits;
  final double? salary;
  final int? maxApplicants;
  final int? currentApplicants;
  final DateTime? deadline;

  JobPost({
    required this.id,
    required this.professorId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.professorName,
    this.requirements,
    this.credits,
    this.salary,
    this.maxApplicants,
    this.currentApplicants,
    this.deadline,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'],
      professorId: json['professor_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      professorName: json['professor_name'] ?? json['professor']?['name'],
      requirements: json['requirements'],
      credits: json['credits'] == null
          ? null
          : (json['credits'] is double
                ? json['credits']
                : double.tryParse(json['credits'].toString())),
      salary: json['salary']?.toDouble(),
      maxApplicants: json['max_applicants'],
      currentApplicants: json['current_applicants'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professor_id': professorId,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'professor_name': professorName,
      'requirements': requirements,
      'credits': credits,
      'salary': salary,
      'max_applicants': maxApplicants,
      'current_applicants': currentApplicants,
      'deadline': deadline?.toIso8601String(),
    };
  }
}

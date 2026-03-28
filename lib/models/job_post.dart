class JobPost {
  final String id;
  final String professorId;
  final String title;
  final String description;
  final String status; // 'open', 'closed', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? requirements;
  final double? credits;

  JobPost({
    required this.id,
    required this.professorId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.requirements,
    this.credits,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'],
      professorId: json['professor_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      requirements: json['requirements'],
      credits: json['credits']?.toDouble(),
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
      'updated_at': updatedAt?.toIso8601String(),
      'requirements': requirements,
      'credits': credits,
    };
  }
}

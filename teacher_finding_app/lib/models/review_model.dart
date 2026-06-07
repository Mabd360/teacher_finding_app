/// Review Model
class Review {
  final String id;
  final int rating;
  final String? comment;
  final String? studentName;
  final String? subject;
  final String? createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.studentName,
    this.subject,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      studentName: json['student_name'],
      subject: json['subject'],
      createdAt: json['created_at'],
    );
  }
}

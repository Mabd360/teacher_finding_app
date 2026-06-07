import 'dart:convert';

/// Teacher Profile Model
/// Represents the teacher profile data structure for serialization/deserialization
class TeacherProfile {
  final String? id;
  final String userId;
  final String name;
  final String? email;
  final List<String> subjects;
  final double feePerHour;
  final dynamic availability;
  final String? bio;
  final String? createdAt;
  final String? updatedAt;
  final double averageRating;
  final int totalReviews;

  TeacherProfile({
    this.id,
    required this.userId,
    required this.name,
    this.email,
    required this.subjects,
    required this.feePerHour,
    this.availability,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  /// Convert JSON response to TeacherProfile object
  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'],
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      subjects: _parseSubjects(json['subjects']),
      feePerHour: double.tryParse(json['fee_per_hour'].toString()) ?? 0.0,
      availability: _parseAvailability(json['availability']),
      bio: json['bio'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
    );
  }

  static List<String> _parseSubjects(dynamic rawSubjects) {
    if (rawSubjects is List) {
      return rawSubjects.map((item) => item.toString()).toList();
    }
    if (rawSubjects is String) {
      try {
        final decoded = jsonDecode(rawSubjects);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        return rawSubjects
            .split(',')
            .map((subject) => subject.trim())
            .where((subject) => subject.isNotEmpty)
            .toList();
      }
    }
    return [];
  }

  static dynamic _parseAvailability(dynamic rawAvailability) {
    if (rawAvailability == null) {
      return null;
    }
    if (rawAvailability is String) {
      try {
        final decoded = jsonDecode(rawAvailability);
        return decoded;
      } catch (_) {
        return rawAvailability;
      }
    }
    return rawAvailability;
  }

  /// Convert TeacherProfile to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'subjects': subjects,
      'fee_per_hour': feePerHour,
      'availability': availability,
      'bio': bio,
    };
  }

  /// Create a copy of TeacherProfile with optional field updates
  TeacherProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    List<String>? subjects,
    double? feePerHour,
    dynamic availability,
    String? bio,
    String? createdAt,
    String? updatedAt,
    double? averageRating,
    int? totalReviews,
  }) {
    return TeacherProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      subjects: subjects ?? this.subjects,
      feePerHour: feePerHour ?? this.feePerHour,
      availability: availability ?? this.availability,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  @override
  String toString() {
    return 'TeacherProfile(id: $id, userId: $userId, name: $name, subjects: $subjects, '
        'feePerHour: $feePerHour, bio: $bio, rating: $averageRating)';
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;
  final String? phone;
  final String? cnicFront;
  final String? cnicBack;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
    this.phone,
    this.cnicFront,
    this.cnicBack,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      phone: json['phone'],
      cnicFront: json['cnic_front'],
      cnicBack: json['cnic_back'],
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'phone': phone,
      'cnic_front': cnicFront,
      'cnic_back': cnicBack,
      'is_verified': isVerified,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    String? phone,
    String? cnicFront,
    String? cnicBack,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      cnicFront: cnicFront ?? this.cnicFront,
      cnicBack: cnicBack ?? this.cnicBack,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
  bool get isAdmin => role == 'admin';

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, isVerified: $isVerified)';
  }
}


/// User data model
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String passwordHash;
  final String role; // 'user' or 'admin'
  final DateTime memberSince;
  final int totalBookings;
  final double rating;
  final int reviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    this.role = 'user',
    required this.memberSince,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.reviews = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create User from SQLite map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      passwordHash: map['password_hash'] as String,
      role: map['role'] as String? ?? 'user',
      memberSince: DateTime.fromMillisecondsSinceEpoch(map['member_since'] as int),
      totalBookings: map['total_bookings'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: map['reviews'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert User to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'role': role,
      'member_since': memberSince.millisecondsSinceEpoch,
      'total_bookings': totalBookings,
      'rating': rating,
      'reviews': reviews,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy of User with optional field updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? passwordHash,
    String? role,
    DateTime? memberSince,
    int? totalBookings,
    double? rating,
    int? reviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      memberSince: memberSince ?? this.memberSince,
      totalBookings: totalBookings ?? this.totalBookings,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
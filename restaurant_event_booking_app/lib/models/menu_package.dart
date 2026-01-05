import 'dart:convert';

/// MenuPackage data model
class MenuPackage {
  final String id;
  final String title;
  final String description;
  final double pricePerGuest;
  final int minGuests;
  final int? maxGuests;
  final String? imagePath;
  final List<String> features;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerGuest,
    required this.minGuests,
    this.maxGuests,
    this.imagePath,
    this.features = const [],
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create MenuPackage from SQLite map
  factory MenuPackage.fromMap(Map<String, dynamic> map) {
    List<String> featuresList = [];
    if (map['features'] != null && map['features'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['features'] as String);
        if (decoded is List) {
          featuresList = decoded.cast<String>();
        }
      } catch (_) {
        // If JSON decode fails, keep empty list
      }
    }

    return MenuPackage(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      pricePerGuest: (map['price_per_guest'] as num).toDouble(),
      minGuests: map['min_guests'] as int,
      maxGuests: map['max_guests'] as int?,
      imagePath: map['image_path'] as String?,
      features: featuresList,
      active: (map['active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert MenuPackage to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price_per_guest': pricePerGuest,
      'min_guests': minGuests,
      'max_guests': maxGuests,
      'image_path': imagePath,
      'features': jsonEncode(features),
      'active': active ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy of MenuPackage with optional field updates
  MenuPackage copyWith({
    String? id,
    String? title,
    String? description,
    double? pricePerGuest,
    int? minGuests,
    int? maxGuests,
    String? imagePath,
    List<String>? features,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuPackage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerGuest: pricePerGuest ?? this.pricePerGuest,
      minGuests: minGuests ?? this.minGuests,
      maxGuests: maxGuests ?? this.maxGuests,
      imagePath: imagePath ?? this.imagePath,
      features: features ?? this.features,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuPackage(id: $id, title: $title, pricePerGuest: $pricePerGuest, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuPackage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
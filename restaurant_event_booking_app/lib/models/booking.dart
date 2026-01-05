/// Enum to represent different booking states
enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  upcoming,
}

/// Extension to convert BookingStatus to/from string
extension BookingStatusExtension on BookingStatus {
  String get name {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.upcoming:
        return 'upcoming';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'upcoming':
        return BookingStatus.upcoming;
      default:
        return BookingStatus.pending;
    }
  }
}

/// Booking data model
class Booking {
  final String id;
  final String userId;
  final String menuPackageId;
  final String title;
  final DateTime eventDate;
  final int guests;
  final double total;
  final BookingStatus status;
  final String? notes;
  final String? contactPhone;
  final String? contactEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.menuPackageId,
    required this.title,
    required this.eventDate,
    required this.guests,
    required this.total,
    required this.status,
    this.notes,
    this.contactPhone,
    this.contactEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create Booking from SQLite map
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      menuPackageId: map['menu_package_id'] as String,
      title: map['title'] as String,
      eventDate: DateTime.fromMillisecondsSinceEpoch(map['event_date'] as int),
      guests: map['guests'] as int,
      total: (map['total'] as num).toDouble(),
      status: BookingStatusExtension.fromString(map['status'] as String),
      notes: map['notes'] as String?,
      contactPhone: map['contact_phone'] as String?,
      contactEmail: map['contact_email'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert Booking to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'menu_package_id': menuPackageId,
      'title': title,
      'event_date': eventDate.millisecondsSinceEpoch,
      'guests': guests,
      'total': total,
      'status': status.name,
      'notes': notes,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy of Booking with optional field updates
  Booking copyWith({
    String? id,
    String? userId,
    String? menuPackageId,
    String? title,
    DateTime? eventDate,
    int? guests,
    double? total,
    BookingStatus? status,
    String? notes,
    String? contactPhone,
    String? contactEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      menuPackageId: menuPackageId ?? this.menuPackageId,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      guests: guests ?? this.guests,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, title: $title, eventDate: $eventDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
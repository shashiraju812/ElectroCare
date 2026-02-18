enum BookingStatus { pending, accepted, completed, cancelled }

class Booking {
  final String id;
  final String userId;
  final String? providerId;
  final String serviceType;
  final String description;
  final String location;
  final DateTime timestamp;
  BookingStatus status;
  final double? price;

  Booking({
    required this.id,
    required this.userId,
    this.providerId,
    required this.serviceType,
    required this.description,
    required this.location,
    required this.timestamp,
    this.status = BookingStatus.pending,
    this.price,
  });

  Booking copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? serviceType,
    String? description,
    String? location,
    DateTime? timestamp,
    BookingStatus? status,
    double? price,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      price: price ?? this.price,
    );
  }
}

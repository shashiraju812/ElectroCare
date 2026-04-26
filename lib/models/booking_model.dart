// lib/models/booking_model.dart
// Firestore-ready model with toMap/fromMap

import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  disputed,
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.accepted: return 'Accepted';
      case BookingStatus.inProgress: return 'In Progress';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
      case BookingStatus.disputed: return 'Disputed';
    }
  }
  bool get isActive => this == BookingStatus.accepted || this == BookingStatus.inProgress;
  bool get isTerminal => this == BookingStatus.completed || this == BookingStatus.cancelled;
}

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String? providerId;
  final String? providerName;
  final String serviceType;
  final String description;
  final String location;
  final DateTime timestamp;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String? providerEta;
  final BookingStatus status;
  final double? estimatedPrice;
  final double? finalPrice;
  final bool isPaid;
  final String? paymentId;
  final String? aiCategory;
  final String? urgency;
  final bool isAppBooking;

  const Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.serviceType,
    required this.description,
    required this.location,
    required this.timestamp,
    this.providerId,
    this.providerName,
    this.scheduledDate,
    this.scheduledTime,
    this.providerEta,
    this.status = BookingStatus.pending,
    this.estimatedPrice,
    this.finalPrice,
    this.isPaid = false,
    this.paymentId,
    this.aiCategory,
    this.urgency,
    this.isAppBooking = true,
  });

  // ── Firestore Serialization ──────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'providerId': providerId,
      'providerName': providerName,
      'serviceType': serviceType,
      'description': description,
      'location': location,
      'timestamp': Timestamp.fromDate(timestamp),
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'scheduledTime': scheduledTime,
      'providerEta': providerEta,
      'status': status.name,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'isPaid': isPaid,
      'paymentId': paymentId,
      'aiCategory': aiCategory,
      'urgency': urgency,
      'isAppBooking': isAppBooking,
    };
  }

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      providerId: map['providerId'],
      providerName: map['providerName'],
      serviceType: map['serviceType'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate(),
      scheduledTime: map['scheduledTime'],
      providerEta: map['providerEta'],
      status: BookingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      estimatedPrice: map['estimatedPrice']?.toDouble(),
      finalPrice: map['finalPrice']?.toDouble(),
      isPaid: map['isPaid'] ?? false,
      paymentId: map['paymentId'],
      aiCategory: map['aiCategory'],
      urgency: map['urgency'],
      isAppBooking: map['isAppBooking'] ?? true,
    );
  }

  Booking copyWith({
    String? providerId,
    String? providerName,
    String? providerEta,
    BookingStatus? status,
    double? estimatedPrice,
    double? finalPrice,
    bool? isPaid,
    String? paymentId,
    String? aiCategory,
    String? urgency,
  }) {
    return Booking(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      serviceType: serviceType,
      description: description,
      location: location,
      timestamp: timestamp,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      isAppBooking: isAppBooking,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerEta: providerEta ?? this.providerEta,
      status: status ?? this.status,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      isPaid: isPaid ?? this.isPaid,
      paymentId: paymentId ?? this.paymentId,
      aiCategory: aiCategory ?? this.aiCategory,
      urgency: urgency ?? this.urgency,
    );
  }
}

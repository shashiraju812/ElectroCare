// lib/services/booking_service.dart
// Firebase BookingService — safe lazy Firestore access

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final List<Booking> _bookings = [];
  StreamSubscription<QuerySnapshot>? _subscription;
  final Set<String> _ignoredByProvider = {};

  // ── NOTE: We do NOT auto-start listening in constructor.
  // Call listenToBookings() only after Firebase is confirmed ready.
  BookingService();

  /// Call this after user logs in (or on app start after Firebase init)
  void listenToBookings() {
    _subscription?.cancel();
    _subscription = _db
        .collection('bookings')
        .snapshots()
        .listen((snapshot) {
      _bookings.clear();
      for (final doc in snapshot.docs) {
        try {
          _bookings.add(Booking.fromMap(doc.id, doc.data()));
        } catch (e) {
          debugPrint('Booking parse error: $e');
        }
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('Booking stream error: $e');
    });
  }

  List<Booking> get allBookings => List.unmodifiable(_bookings);

  List<Booking> getUserBookings(String userId) =>
      _bookings.where((b) => b.userId == userId || userId.isEmpty).toList();

  List<Booking> getPendingBookings() =>
      _bookings.where((b) => b.status == BookingStatus.pending).toList();

  List<Booking> getAvailableBookings(String providerId) => _bookings
      .where((b) =>
          b.status == BookingStatus.pending &&
          !_ignoredByProvider.contains(b.id))
      .toList();

  List<Booking> getProviderBookings(String providerId) =>
      _bookings.where((b) => b.providerId == providerId).toList();

  Future<void> createBooking(Booking booking) async {
    try {
      await _db.collection('bookings').add(booking.toMap());
    } catch (e) {
      debugPrint('createBooking error: $e');
    }
  }

  Future<void> acceptBooking({
    required String bookingId,
    required String providerId,
    required String providerName,
    required String eta,
  }) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.accepted.name,
        'providerId': providerId,
        'providerName': providerName,
        'providerEta': eta,
      });
    } catch (e) {
      debugPrint('acceptBooking error: $e');
    }
  }

  Future<void> ignoreBooking(String bookingId) async {
    _ignoredByProvider.add(bookingId);
    notifyListeners();
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': status.name,
      });
    } catch (e) {
      debugPrint('updateBookingStatus error: $e');
    }
  }

  Future<void> markInProgress(String bookingId) =>
      updateBookingStatus(bookingId, BookingStatus.inProgress);

  Future<void> cancelBooking(String bookingId) =>
      updateBookingStatus(bookingId, BookingStatus.cancelled);

  Future<void> completeBooking(String bookingId, {double finalPrice = 0}) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.completed.name,
        'finalPrice': finalPrice,
      });
    } catch (e) {
      debugPrint('completeBooking error: $e');
    }
  }

  int get totalBookings => _bookings.length;
  int get pendingCount =>
      _bookings.where((b) => b.status == BookingStatus.pending).length;
  int get completedCount =>
      _bookings.where((b) => b.status == BookingStatus.completed).length;
  double get totalRevenue => _bookings
      .where((b) => b.finalPrice != null)
      .fold(0.0, (total, b) => total + (b.finalPrice ?? 0));

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

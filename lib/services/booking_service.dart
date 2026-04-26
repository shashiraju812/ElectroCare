// lib/services/booking_service.dart
// Firebase BookingService — reads/writes to Firestore /bookings collection

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Booking> _bookings = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  // ── Ignored booking IDs (provider-local) ─────────────────────────
  final Set<String> _ignoredByProvider = {};

  BookingService() {
    _listenToBookings();
  }

  /// Listen to Firestore /bookings in real time
  void _listenToBookings() {
    _subscription = _db
        .collection('bookings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _bookings.clear();
      for (final doc in snapshot.docs) {
        _bookings.add(Booking.fromMap(doc.id, doc.data()));
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

  /// Returns bookings available for a provider to accept (pending & not ignored)
  List<Booking> getAvailableBookings(String providerId) =>
      _bookings
          .where((b) =>
              b.status == BookingStatus.pending &&
              !_ignoredByProvider.contains(b.id))
          .toList();

  List<Booking> getProviderBookings(String providerId) =>
      _bookings.where((b) => b.providerId == providerId).toList();

  Future<void> createBooking(Booking booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  Future<void> acceptBooking({
    required String bookingId,
    required String providerId,
    required String providerName,
    required String eta,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.accepted.name,
      'providerId': providerId,
      'providerName': providerName,
      'providerEta': eta,
    });
  }

  /// Provider swipes away / ignores a booking (hides it from their list)
  Future<void> ignoreBooking(String bookingId) async {
    _ignoredByProvider.add(bookingId);
    notifyListeners();
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status.name,
    });
  }

  /// Mark as in-progress (alias for updateBookingStatus)
  Future<void> markInProgress(String bookingId) =>
      updateBookingStatus(bookingId, BookingStatus.inProgress);

  Future<void> cancelBooking(String bookingId) =>
      updateBookingStatus(bookingId, BookingStatus.cancelled);

  Future<void> completeBooking(String bookingId, {double finalPrice = 0}) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.completed.name,
      'finalPrice': finalPrice,
    });
  }

  // Stats
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

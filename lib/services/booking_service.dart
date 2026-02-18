import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  final List<Booking> _bookings = [];

  // Get all bookings (for demo purposes/admin)
  List<Booking> get bookings => List.unmodifiable(_bookings);

  // Get pending bookings for providers
  List<Booking> get openBookings =>
      _bookings.where((b) => b.status == BookingStatus.pending).toList();

  // Get bookings for a specific user
  List<Booking> getUserBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  // Get bookings for a specific provider
  List<Booking> getProviderBookings(String providerId) {
    return _bookings.where((b) => b.providerId == providerId).toList();
  }

  Future<void> createBooking(Booking booking) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _bookings.add(booking);
    notifyListeners();
  }

  Future<void> acceptBooking(String bookingId, String providerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.accepted,
        providerId: providerId,
      );
      notifyListeners();
    }
  }

  Future<void> completeBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.completed,
      );
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
      );
      notifyListeners();
    }
  }
}

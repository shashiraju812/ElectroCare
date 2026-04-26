// lib/services/payment_service.dart
// Mock payment service — no Razorpay

import 'package:flutter/foundation.dart';

class PaymentService extends ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  void initialize() {
    // Razorpay init goes here when key is available
  }

  Future<bool> processPayment({
    required double amount,
    required String orderId,
    required String description,
    required String userName,
    required String userPhone,
    required String userEmail,
  }) async {
    _isProcessing = true;
    notifyListeners();
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    _isProcessing = false;
    notifyListeners();
    return true; // Mock success
  }

}

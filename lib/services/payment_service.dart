// lib/services/payment_service.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum PaymentMethod {
  upi,
  card,
  netBanking,
  cashOnDelivery,
}

class Transaction {
  final String id;
  final double amount;
  final PaymentMethod method;
  final DateTime timestamp;
  final String status; // 'success', 'pending', 'failed'

  Transaction({
    required this.id,
    required this.amount,
    required this.method,
    required this.timestamp,
    required this.status,
  });
}

class PaymentService extends ChangeNotifier {
  final _uuid = const Uuid();

  /// Simulate a payment process
  Future<Transaction?> processPayment({
    required double amount,
    required PaymentMethod method,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, we'll assume 95% success rate
    bool isSuccess = true; // Always success for this demo unless manually failed

    if (isSuccess) {
      final transaction = Transaction(
        id: 'TXN-${_uuid.v4().substring(0, 8).toUpperCase()}',
        amount: amount,
        method: method,
        timestamp: DateTime.now(),
        status: 'success',
      );
      return transaction;
    }
    return null;
  }
}

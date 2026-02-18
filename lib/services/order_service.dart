import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class OrderService extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> getUserOrders(String userId) {
    return _orders.where((o) => o.userId == userId).toList();
  }

  Future<void> placeOrder(
    String userId,
    List<CartItem> items,
    double total,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      items: List.from(items), // Create a copy
      totalAmount: total,
      timestamp: DateTime.now(),
      status: OrderStatus.processing,
    );

    _orders.insert(0, newOrder); // Add to top
    notifyListeners();
  }
}

// lib/services/order_service.dart
// Firebase OrderService — reads/writes to Firestore /orders collection

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/product_model.dart';

class OrderService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Order> _orders = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  List<Order> get allOrders => List.unmodifiable(_orders);

  /// Start listening to orders (call after user login)
  void listenToAllOrders() {
    _subscription?.cancel();
    _subscription = _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _orders.clear();
      for (final doc in snapshot.docs) {
        _orders.add(Order.fromMap(doc.id, doc.data()));
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('Order stream error: $e');
    });
  }

  List<Order> getUserOrders(String userId) =>
      _orders.where((o) => o.userId == userId).toList();

  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> cartItems,
    required String address,
  }) async {
    final order = Order(
      id: '',  // Firestore will generate the ID
      userId: userId,
      items: cartItems
          .map((ci) => OrderItem(
                productId: ci.product.id,
                productName: ci.product.name,
                price: ci.product.effectivePrice,
                quantity: ci.quantity,
              ))
          .toList(),
      totalAmount: cartItems.fold<double>(0.0, (total, ci) => total + ci.total),
      createdAt: DateTime.now(),
      address: address,
    );

    final docRef = await _db.collection('orders').add(order.toMap());

    // Return order with Firestore-generated ID
    final placed = Order(
      id: docRef.id,
      userId: order.userId,
      items: order.items,
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
      address: order.address,
    );

    // Local update (stream will catch up too)
    _orders.insert(0, placed);
    notifyListeners();
    return placed;
  }

  // Stats
  int get totalOrders => _orders.length;
  double get totalRevenue => _orders.fold<double>(0.0, (total, o) => total + o.totalAmount);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

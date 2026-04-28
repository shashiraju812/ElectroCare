// lib/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    productId: map['productId'] ?? '',
    productName: map['productName'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    quantity: map['quantity'] ?? 1,
  );
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final String? address;
  final String? paymentId;
  final bool isPaid;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.address,
    this.paymentId,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'items': items.map((i) => i.toMap()).toList(),
    'totalAmount': totalAmount,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'address': address,
    'paymentId': paymentId,
    'isPaid': isPaid,
  };

  factory Order.fromMap(String id, Map<String, dynamic> map) => Order(
    id: id,
    userId: map['userId'] ?? '',
    items: (map['items'] as List<dynamic>?)
        ?.map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
        .toList() ?? [],
    totalAmount: (map['totalAmount'] ?? 0).toDouble(),
    status: OrderStatus.values.firstWhere(
      (s) => s.name == map['status'],
      orElse: () => OrderStatus.pending,
    ),
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    address: map['address'],
    paymentId: map['paymentId'],
    isPaid: map['isPaid'] ?? false,
  );
}

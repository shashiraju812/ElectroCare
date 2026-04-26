// lib/models/product_model.dart
// Firestore-ready model with toMap/fromMap

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final String category;
  final int stock;
  final double rating;
  final int reviewCount;
  final String? ownerId;
  final bool isActive;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.discountPrice,
    this.stock = 10,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.ownerId,
    this.isActive = true,
    this.createdAt,
  });

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  int get discountPercent =>
      hasDiscount ? (((price - discountPrice!) / price) * 100).round() : 0;

  // ── Firestore Serialization ──────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'ownerId': ownerId,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null ? (map['discountPrice']).toDouble() : null,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'Other',
      stock: map['stock'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      ownerId: map['ownerId'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    String? category,
    int? stock,
    bool? isActive,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      rating: rating,
      reviewCount: reviewCount,
      ownerId: ownerId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

// ── CartItem ──────────────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.effectivePrice * quantity;

  /// Alias used by some screens
  double get totalPrice => total;
}

// ── Order ─────────────────────────────────────────────────────────
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

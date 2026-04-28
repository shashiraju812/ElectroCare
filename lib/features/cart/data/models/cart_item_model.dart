// lib/features/cart/data/models/cart_item_model.dart
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.price,
    required super.quantity,
    required super.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      price: entity.price,
      quantity: entity.quantity,
      imageUrl: entity.imageUrl,
    );
  }
}

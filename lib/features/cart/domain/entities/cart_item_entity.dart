// lib/features/cart/domain/entities/cart_item_entity.dart

class CartItemEntity {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get total => price * quantity;

  CartItemEntity copyWith({
    int? quantity,
  }) {
    return CartItemEntity(
      id: id,
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }
}

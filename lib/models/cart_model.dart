// lib/models/cart_model.dart
import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.effectivePrice * quantity;

  /// Alias used by some screens
  double get totalPrice => total;
}

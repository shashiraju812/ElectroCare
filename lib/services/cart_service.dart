// lib/services/cart_service.dart
// In-memory cart service — no Hive/Firebase needed

import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price of all items in cart
  double get total => _items.fold(0.0, (sum, item) => sum + item.total);

  /// Alias used by some screens
  double get totalAmount => total;

  bool get isEmpty => _items.isEmpty;

  bool contains(String productId) =>
      _items.any((item) => item.product.id == productId);

  int quantityOf(String productId) {
    try {
      return _items.firstWhere((i) => i.product.id == productId).quantity;
    } catch (_) {
      return 0;
    }
  }

  /// Add product to cart — used by new code
  void addItem(Product product, {int qty = 1}) {
    final i = _items.indexWhere((item) => item.product.id == product.id);
    if (i >= 0) {
      _items[i].quantity += qty;
    } else {
      _items.add(CartItem(product: product, quantity: qty));
    }
    notifyListeners();
  }

  /// Alias used by legacy screens calling addToCart
  void addToCart(Product product, {int qty = 1}) => addItem(product, qty: qty);

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Update quantity of a specific item (set absolute value)
  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final i = _items.indexWhere((item) => item.product.id == productId);
    if (i >= 0) {
      _items[i].quantity = qty;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    final i = _items.indexWhere((item) => item.product.id == productId);
    if (i >= 0) {
      if (_items[i].quantity <= 1) {
        _items.removeAt(i);
      } else {
        _items[i].quantity--;
      }
      notifyListeners();
    }
  }

  /// Clear the entire cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Alias used by legacy screens
  void clearCart() => clear();
}

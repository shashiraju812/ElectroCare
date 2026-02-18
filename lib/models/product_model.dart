class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.stock = 10,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    this.status = OrderStatus.pending,
  });
}

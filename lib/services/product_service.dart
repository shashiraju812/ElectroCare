import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductService extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: "Philips Essential LED Bulb (9W, B22)",
      description:
          "Energy-efficient 9W LED bulb providing 806 lumens of cool daylight. Designed for longevity with up to 15,000 hours of life. Perfect for home and office use.",
      price: 155,
      imageUrl: "https://m.media-amazon.com/images/I/51sh6-5N6iL._SL1000_.jpg",
      category: "Lighting",
    ),
    Product(
      id: '2',
      name: "Anchor Roma Classic 6-Module Switch Plate",
      description:
          "Premium modular switch plate with a sleek, gloss finish. Made from high-quality polycarbonate material, flame retardant and shockproof.",
      price: 285,
      imageUrl: "https://m.media-amazon.com/images/I/41-lS0p6ZpL._SL1000_.jpg",
      category: "Electrical",
    ),
    Product(
      id: '3',
      name: "Finolex 1.5 sqmm FR PVC Insulated Cable (10m)",
      description:
          "Pure electrolytic grade copper wire with Flame Retardant (FR) properties. Ideal for internal house wiring with high safety standards.",
      price: 450,
      imageUrl: "https://m.media-amazon.com/images/I/61NfT+I+fSL._SL1100_.jpg",
      category: "Wiring",
    ),
    Product(
      id: '4',
      name: "Belkin 4-Socket Surge Protector Extension",
      description:
          "Advanced surge protection for your valuable electronics. Features 4 universal sockets, a heavy-duty 2-meter cable, and a master switch.",
      price: 999,
      imageUrl: "https://m.media-amazon.com/images/I/51rP8uYQdPL._SL1000_.jpg",
      category: "Accessories",
    ),
    Product(
      id: '5',
      name: "Crompton Hill Briz 1200mm Ceiling Fan",
      description:
          "High-speed ceiling fan with a powerful motor and aerodynamic blades for superior air delivery (210 CMM). Energy-efficient and silent operation.",
      price: 1850,
      imageUrl: "https://m.media-amazon.com/images/I/618BfRz+fML._SL1500_.jpg",
      category: "Appliances",
    ),
    Product(
      id: '6',
      name: "Havells Euro-II Series 32A Double Pole MCB",
      description:
          "Double Pole Miniature Circuit Breaker (MCB) with C-Curve characteristic. Provides reliable protection against short circuits and overloads.",
      price: 320,
      imageUrl: "https://m.media-amazon.com/images/I/61tJ+5fS4JL._SL1500_.jpg",
      category: "Protection",
    ),
  ];

  List<Product> get products => List.unmodifiable(_products);

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

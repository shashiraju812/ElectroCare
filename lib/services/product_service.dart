import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductService extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: "LED Bulb (9W)",
      description:
          "High efficiency 9W LED bulb with 1 year warranty. Cool Daylight.",
      price: 120,
      imageUrl: "https://via.placeholder.com/150?text=Bulb",
      category: "Lighting",
    ),
    Product(
      id: '2',
      name: "Switch Board (6M)",
      description:
          "Modular switch board plate, 6 modules. Flame retardant material.",
      price: 250,
      imageUrl: "https://via.placeholder.com/150?text=Switch",
      category: "Electrical",
    ),
    Product(
      id: '3',
      name: "Copper Wire (1m)",
      description: "Pure copper wire 1.5sqmm red color for house wiring.",
      price: 40,
      imageUrl: "https://via.placeholder.com/150?text=Wire",
      category: "Wiring",
    ),
    Product(
      id: '4',
      name: "Extension Box",
      description:
          "4 Universal sockets with individual switches and indicator.",
      price: 350,
      imageUrl: "https://via.placeholder.com/150?text=Box",
      category: "Accessories",
    ),
    Product(
      id: '5',
      name: "Ceiling Fan",
      description: "High speed ceiling fan 1200mm sweep. Energy saving.",
      price: 1500,
      imageUrl: "https://via.placeholder.com/150?text=Fan",
      category: "Appliances",
    ),
    Product(
      id: '6',
      name: "MCB 32A",
      description: "Double pole MCB 32A C-Curve. Short circuit protection.",
      price: 180,
      imageUrl: "https://via.placeholder.com/150?text=MCB",
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

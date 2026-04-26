// lib/services/product_service.dart
// Firebase ProductService — reads/writes to Firestore /products collection

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Product> _products = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = true;

  ProductService() {
    _listenToProducts();
  }

  /// Listen to Firestore /products in real time
  void _listenToProducts() {
    _isLoading = true;
    notifyListeners();

    _subscription = _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _products.clear();
      for (final doc in snapshot.docs) {
        _products.add(Product.fromMap(doc.id, doc.data()));
      }

      // Seed initial products if collection is empty (first run)
      if (_products.isEmpty) {
        _seedInitialProducts();
      }

      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Product stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Seed demo products on first run
  Future<void> _seedInitialProducts() async {
    final seedProducts = [
      const Product(
        id: '', name: 'Philips Essential LED Bulb 9W',
        description: 'Energy-efficient 9W LED bulb. 15,000 hour lifespan. Cool daylight.',
        price: 185, discountPrice: 155,
        imageUrl: 'https://images.unsplash.com/photo-1579101773206-155a50900f11?w=400&h=400&fit=crop',
        category: 'Lighting', stock: 150, rating: 4.5, reviewCount: 1240,
      ),
      const Product(
        id: '', name: 'Anchor Roma 6-Module Switch Plate',
        description: 'Premium modular switch plate, polycarbonate, flame retardant.',
        price: 320, discountPrice: 285,
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
        category: 'Electrical', stock: 75, rating: 4.3, reviewCount: 523,
      ),
      const Product(
        id: '', name: 'Finolex 1.5 sqmm FR Cable (10m)',
        description: 'Pure copper wire with Flame Retardant properties for house wiring.',
        price: 520, discountPrice: 450,
        imageUrl: 'https://images.unsplash.com/photo-1517694712202-14819f60b6fe?w=400&h=400&fit=crop',
        category: 'Wiring', stock: 200, rating: 4.6, reviewCount: 867,
      ),
      const Product(
        id: '', name: 'Havells Crabtree Athena MCB 32A',
        description: 'Single pole MCB, 32A, 10kA, ISI marked. Protects from overload.',
        price: 290, discountPrice: 240,
        imageUrl: 'https://images.unsplash.com/photo-1583622402411-041fb48a1fb5?w=400&h=400&fit=crop',
        category: 'Safety', stock: 60, rating: 4.7, reviewCount: 431,
      ),
      const Product(
        id: '', name: 'Syska PAR LED Spotlight 7W',
        description: 'GU10 base spotlight for living rooms. Warm white 3000K, 600 lumens.',
        price: 240, discountPrice: 199,
        imageUrl: 'https://images.unsplash.com/photo-1565636192335-14c46fa1120d?w=400&h=400&fit=crop',
        category: 'Lighting', stock: 80, rating: 4.2, reviewCount: 319,
      ),
      const Product(
        id: '', name: 'Panasonic 5A 3-Pin Socket (White)',
        description: '3-pin socket, ISI marked, with child safety shutter.',
        price: 95,
        imageUrl: 'https://images.unsplash.com/photo-1565632066482-577d38673c7d?w=400&h=400&fit=crop',
        category: 'Electrical', stock: 300, rating: 4.1, reviewCount: 788,
      ),
      const Product(
        id: '', name: 'Havells DIGISURGE 8-Socket Surge Guard',
        description: '8-socket power strip with surge protection. 4m cord.',
        price: 1250, discountPrice: 999,
        imageUrl: 'https://images.unsplash.com/photo-1612198188060-c7c2a3b66eae?w=400&h=400&fit=crop',
        category: 'Safety', stock: 40, rating: 4.4, reviewCount: 2140,
      ),
      const Product(
        id: '', name: 'Legrand Arteor RCCB 40A 30mA',
        description: 'Earth leakage circuit breaker, protects against electric shocks.',
        price: 1850, discountPrice: 1499,
        imageUrl: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=400&h=400&fit=crop',
        category: 'Safety', stock: 25, rating: 4.8, reviewCount: 156,
      ),
    ];

    final batch = _db.batch();
    for (final p in seedProducts) {
      batch.set(_db.collection('products').doc(), p.toMap());
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ── Getters ──────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch && p.isActive;
    }).toList();
  }

  List<Product> get featuredProducts =>
      _products.where((p) => p.rating >= 4.5 && p.isActive).take(4).toList();

  List<Product> get allProducts => List.unmodifiable(_products);

  // ── Actions ──────────────────────────────────────────────
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  Future<void> updateProduct(Product updated) async {
    await _db.collection('products').doc(updated.id).update(updated.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Stats
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.stock < 10).length;
  double get totalInventoryValue =>
      _products.fold(0.0, (total, p) => total + p.price * p.stock);
}

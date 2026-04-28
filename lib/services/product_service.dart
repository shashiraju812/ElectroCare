// lib/services/product_service.dart
// Firebase ProductService — reads/writes to Firestore /products collection

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService extends ChangeNotifier {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
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
        .snapshots()
        .listen((snapshot) {
      _products.clear();
      for (final doc in snapshot.docs) {
        try {
          _products.add(Product.fromMap(doc.id, doc.data()));
        } catch (e) {
          debugPrint('Product parse error: $e');
        }
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
        description: 'A60-shape retrofit LED lamp for E27 fixtures delivering 900 lm at 100 lm/W efficacy. '
            'Frosted diffuser ensures 150° uniform light distribution. CRI ≥ 80, CCT options: 3000K / 4000K / 6500K. '
            'Mercury-free, no UV/IR. Rated 10,000–15,000 hrs, 50,000 switching cycles. '
            'Max T-case 90°C. Operating range −20°C to +45°C. Input: 220–240V, 50/60Hz.',
        price: 185, discountPrice: 155,
        imageUrl: 'assets/images/led_bulb.png',
        category: 'Lighting', stock: 150, rating: 4.5, reviewCount: 1240,
      ),
      const Product(
        id: '', name: 'Anchor Roma 6-Module Switch Plate',
        description: 'Flame-retardant polycarbonate modular plate (220×90 mm) housing 6 control modules. '
            'High-glow matte white finish resists yellowing and dust. Snap-fit mechanism with captive screw terminals. '
            'Supports horizontal and vertical installation. IP20 rated for indoor use. '
            'Compatible with Roma Classic, Urban, Tresa, and Plus aesthetic lines.',
        price: 320, discountPrice: 285,
        imageUrl: 'assets/images/switch_plate.png',
        category: 'Electrical', stock: 75, rating: 4.3, reviewCount: 523,
      ),
      const Product(
        id: '', name: 'Finolex 1.5 sqmm FR Cable (10m)',
        description: 'Multi-strand flexible Class 5 conductor (1.5 sqmm) with ≥99.97% pure electrolytic copper — '
            'conductivity exceeding 100% IACS. FR PVC Type D insulation: Critical Oxygen Index ≥29%, '
            'Temperature Index ≥250°C — self-extinguishing without external flame. '
            'Rated 1100V, ~13–15A. IS 694:2010 compliant. ISI & Flamegard marked. '
            'Available in Red, Black, Yellow, Green, Blue.',
        price: 520, discountPrice: 450,
        imageUrl: 'assets/images/copper_wire.png',
        category: 'Wiring', stock: 200, rating: 4.6, reviewCount: 867,
      ),
      const Product(
        id: '', name: 'Havells Crabtree Athena MCB 32A',
        description: 'C-Curve miniature circuit breaker rated 32A for high-load circuits (A/C, geysers). '
            'Breaking capacity: 3kA — suitable for standard residential fault levels. '
            'C-Curve tripping handles moderate inductive starting currents without nuisance trip. '
            'UV-stabilized unbreakable polycarbonate body. Rated 240V, 50Hz AC. '
            'Available in Single Pole (SP) and Double Pole (DP). Sleek white Athena finish.',
        price: 290, discountPrice: 240,
        imageUrl: 'assets/images/mcb_breaker.png',
        category: 'Safety', stock: 60, rating: 4.7, reviewCount: 431,
      ),
      const Product(
        id: '', name: 'Syska PAR LED Spotlight 7W',
        description: 'Precision accent spotlight engineered for Indian voltage conditions (90–300V AC). '
            'SSK-SMR variant: 480 lm output, aluminum + thermoplastic housing, IP44 rated. '
            'SSK-PAP variant: 700 lm, up to 240° beam angle, IP20 polycarbonate. '
            'Color options: 3000K–6500K and RGB+White. Ideal for showrooms, malls, residential accents.',
        price: 240, discountPrice: 199,
        imageUrl: 'assets/images/syska_spotlight.png',
        category: 'Lighting', stock: 80, rating: 4.2, reviewCount: 319,
      ),
      const Product(
        id: '', name: 'Panasonic 5A 3-Pin Socket (White)',
        description: 'IS 1293 compliant 5A 3-pin power socket with child safety shutters — '
            'prevents accidental contact with live parts. Tough Contact technology: '
            'rolled thin-plate springs provide high elasticity, preventing disconnection under mechanical impact. '
            'High-grade heat-resistant, non-flammable polycarbonate body. '
            'Available in Matte White, Matte Black, and Ivory. Super Plug Top compatible.',
        price: 95,
        imageUrl: 'assets/images/socket_outlet.png',
        category: 'Electrical', stock: 300, rating: 4.1, reviewCount: 788,
      ),
      const Product(
        id: '', name: 'Havells DIGISURGE 8-Socket Surge Guard',
        description: 'Type 3 point-of-use surge protection device with 8 universal sockets and 4m cord. '
            'Shunts voltage transients at point-of-use — ideal for computers, home theaters, AV equipment. '
            'Protection modes: Line-to-Neutral, Line-to-Earth, Neutral-to-Earth. '
            'Master on/off switch with indicator LEDs for surge protection and grounding status. '
            'IS 16192 compliant. Robust construction with multiple plug configurations.',
        price: 1250, discountPrice: 999,
        imageUrl: 'assets/images/surge_protector.png',
        category: 'Safety', stock: 40, rating: 4.4, reviewCount: 2140,
      ),
      const Product(
        id: '', name: 'Legrand Arteor RCCB 40A 30mA',
        description: 'IEC 61008-1 certified 2-pole Residual Current Circuit Breaker — '
            'detects leakage currents as low as 30mA and disconnects in milliseconds to prevent electrocution. '
            'Rated 40A continuous current, 10kA breaking capacity. Type AC/A/F for broad compatibility. '
            'DX3/TX3 series: high immunity to unwanted tripping, bi-connect terminals, '
            'label holder for circuit ID. Grey RAL 7035. 3D CAD models (.DWG) available from Legrand e-Catalogue.',
        price: 1850, discountPrice: 1499,
        imageUrl: 'assets/images/rccb_breaker.png',
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

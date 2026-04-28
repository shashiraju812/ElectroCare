// services/firestore_init_service.dart
// Firestore collections initialization and structure setup

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInitService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Initialize all Firestore collections
  static Future<void> initializeCollections() async {
    try {
      debugPrint('🔧 Initializing Firestore collections...');

      // Create users collection structure
      await _createUsersCollection();

      // Create products collection structure
      await _createProductsCollection();

      // Create orders collection structure
      await _createOrdersCollection();

      // Create services collection structure
      await _createServicesCollection();

      // Create bookings collection structure
      await _createBookingsCollection();

      // Create reviews collection structure
      await _createReviewsCollection();

      // Create categories collection
      await _createCategoriesCollection();

      // Create addresses collection
      await _createAddressesCollection();

      debugPrint('✅ Firestore collections initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing collections: $e');
      rethrow;
    }
  }

  /// Create users collection with example document
  static Future<void> _createUsersCollection() async {
    try {
      final doc = _db.collection('users').doc('_schema_');
      await doc.set({
        'uid': 'string',
        'name': 'string',
        'email': 'string',
        'phone': 'string',
        'role': 'enum(user, provider, owner)',
        'profileImageUrl': 'string | null',
        'isActive': 'boolean',
        'isVerified': 'boolean',
        'rating': 'number',
        'totalJobs': 'number',
        'address': 'string | null',
        'createdAt': 'timestamp',
        'lastSeen': 'timestamp | null',
      }, SetOptions(merge: true));
      debugPrint('✓ Users collection initialized');
    } catch (e) {
      debugPrint('Error creating users collection: $e');
    }
  }

  /// Create products collection
  static Future<void> _createProductsCollection() async {
    try {
      final doc = _db.collection('products').doc('_schema_');
      await doc.set({
        'id': 'string',
        'name': 'string',
        'description': 'string',
        'price': 'number',
        'discountPrice': 'number | null',
        'imageUrl': 'string',
        'category': 'string',
        'stock': 'number',
        'rating': 'number',
        'reviewCount': 'number',
        'ownerId': 'string',
        'isActive': 'boolean',
        'createdAt': 'timestamp',
        'tags': 'array<string>',
        'specifications': 'map<string, any>',
      }, SetOptions(merge: true));
      debugPrint('✓ Products collection initialized');
    } catch (e) {
      debugPrint('Error creating products collection: $e');
    }
  }

  /// Create orders collection
  static Future<void> _createOrdersCollection() async {
    try {
      final doc = _db.collection('orders').doc('_schema_');
      await doc.set({
        'orderId': 'string',
        'customerId': 'string',
        'shopOwnerId': 'string',
        'serviceProviderId': 'string | null',
        'items': 'array<{productId, quantity, price}>',
        'status': 'enum(pending, confirmed, processing, shipped, delivered, cancelled)',
        'totalAmount': 'number',
        'deliveryAddress': 'string',
        'lastLocation': 'map<latitude, longitude, address>',
        'lastLocationUpdate': 'timestamp',
        'createdAt': 'timestamp',
        'updatedAt': 'timestamp',
        'deliveryDate': 'timestamp | null',
        'paymentStatus': 'enum(pending, completed, failed)',
        'notes': 'string | null',
      }, SetOptions(merge: true));
      debugPrint('✓ Orders collection initialized');
    } catch (e) {
      debugPrint('Error creating orders collection: $e');
    }
  }

  /// Create services collection
  static Future<void> _createServicesCollection() async {
    try {
      final doc = _db.collection('services').doc('_schema_');
      await doc.set({
        'serviceId': 'string',
        'name': 'string',
        'description': 'string',
        'category': 'string',
        'price': 'number',
        'estimatedDuration': 'number(minutes)',
        'providerId': 'string',
        'isActive': 'boolean',
        'rating': 'number',
        'reviewCount': 'number',
        'serviceArea': 'array<string>',
        'createdAt': 'timestamp',
        'imageUrl': 'string | null',
      }, SetOptions(merge: true));
      debugPrint('✓ Services collection initialized');
    } catch (e) {
      debugPrint('Error creating services collection: $e');
    }
  }

  /// Create bookings collection
  static Future<void> _createBookingsCollection() async {
    try {
      final doc = _db.collection('bookings').doc('_schema_');
      await doc.set({
        'bookingId': 'string',
        'customerId': 'string',
        'serviceId': 'string',
        'providerId': 'string',
        'bookingDate': 'timestamp',
        'completionDate': 'timestamp | null',
        'status': 'enum(pending, confirmed, in_progress, completed, cancelled)',
        'location': 'map<latitude, longitude, address>',
        'notes': 'string | null',
        'cost': 'number',
        'rating': 'number | null',
        'review': 'string | null',
        'createdAt': 'timestamp',
      }, SetOptions(merge: true));
      debugPrint('✓ Bookings collection initialized');
    } catch (e) {
      debugPrint('Error creating bookings collection: $e');
    }
  }

  /// Create reviews collection
  static Future<void> _createReviewsCollection() async {
    try {
      final doc = _db.collection('reviews').doc('_schema_');
      await doc.set({
        'reviewId': 'string',
        'itemId': 'string(productId or serviceId)',
        'itemType': 'enum(product, service)',
        'userId': 'string',
        'rating': 'number(1-5)',
        'title': 'string',
        'text': 'string',
        'images': 'array<string>',
        'helpful': 'number',
        'createdAt': 'timestamp',
        'updatedAt': 'timestamp',
      }, SetOptions(merge: true));
      debugPrint('✓ Reviews collection initialized');
    } catch (e) {
      debugPrint('Error creating reviews collection: $e');
    }
  }

  /// Create categories collection with predefined categories
  static Future<void> _createCategoriesCollection() async {
    try {
      final categories = [
        {
          'id': 'wiring',
          'name': 'Wiring & Cables',
          'icon': '🔌',
          'description': 'Electrical wires and cables',
        },
        {
          'id': 'switches',
          'name': 'Switches & Outlets',
          'icon': '🔘',
          'description': 'Light switches and power outlets',
        },
        {
          'id': 'bulbs',
          'name': 'Bulbs & Lighting',
          'icon': '💡',
          'description': 'LED and traditional bulbs',
        },
        {
          'id': 'tools',
          'name': 'Tools & Equipment',
          'icon': '🔧',
          'description': 'Electrical tools and equipment',
        },
        {
          'id': 'panels',
          'name': 'Panels & Boards',
          'icon': '📦',
          'description': 'Distribution panels and circuit boards',
        },
        {
          'id': 'safety',
          'name': 'Safety Equipment',
          'icon': '🛡️',
          'description': 'Circuit breakers and safety devices',
        },
      ];

      for (final category in categories) {
        await _db
            .collection('categories')
            .doc(category['id'] as String)
            .set(category, SetOptions(merge: true));
      }
      debugPrint('✓ Categories collection initialized');
    } catch (e) {
      debugPrint('Error creating categories collection: $e');
    }
  }

  /// Create addresses collection structure
  static Future<void> _createAddressesCollection() async {
    try {
      final doc = _db.collection('addresses').doc('_schema_');
      await doc.set({
        'addressId': 'string',
        'userId': 'string',
        'name': 'string',
        'street': 'string',
        'city': 'string',
        'state': 'string',
        'zipCode': 'string',
        'country': 'string',
        'phone': 'string',
        'isDefault': 'boolean',
        'latitude': 'number',
        'longitude': 'number',
        'createdAt': 'timestamp',
        'updatedAt': 'timestamp',
      }, SetOptions(merge: true));
      debugPrint('✓ Addresses collection initialized');
    } catch (e) {
      debugPrint('Error creating addresses collection: $e');
    }
  }

  /// Create sample products
  static Future<void> createSampleProducts() async {
    try {
      final products = [
        {
          'name': 'LED Bulb 10W',
          'description': 'Bright LED bulb with long lifespan',
          'price': 250.0,
          'imageUrl': 'https://placehold.co/400x400/png?text=LED+Bulb',
          'category': 'bulbs',
          'stock': 50,
          'rating': 4.5,
          'reviewCount': 12,
        },
        {
          'name': 'Copper Wire 1.5mm',
          'description': 'High quality copper wire for wiring',
          'price': 45.0,
          'imageUrl': 'https://placehold.co/400x400/png?text=Copper+Wire',
          'category': 'wiring',
          'stock': 100,
          'rating': 4.7,
          'reviewCount': 25,
        },
        {
          'name': 'Wall Switch',
          'description': 'Modern white wall switch plate',
          'price': 120.0,
          'imageUrl': 'https://placehold.co/400x400/png?text=Wall+Switch',
          'category': 'switches',
          'stock': 75,
          'rating': 4.3,
          'reviewCount': 18,
        },
      ];

      for (final product in products) {
        await _db.collection('products').add(product);
      }
      debugPrint('✓ Sample products created');
    } catch (e) {
      debugPrint('Error creating sample products: $e');
    }
  }

  /// Check collection exists and has data
  static Future<bool> collectionExists(String collectionName) async {
    try {
      final snapshot = await _db.collection(collectionName).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get app statistics
  static Future<Map<String, dynamic>> getAppStats() async {
    try {
      final usersCount = (await _db.collection('users').count().get()).count ?? 0;
      final productsCount = (await _db.collection('products').count().get()).count ?? 0;
      final ordersCount = (await _db.collection('orders').count().get()).count ?? 0;
      final bookingsCount = (await _db.collection('bookings').count().get()).count ?? 0;

      return {
        'users': usersCount,
        'products': productsCount,
        'orders': ordersCount,
        'bookings': bookingsCount,
      };
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return {};
    }
  }
}

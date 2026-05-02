// services/firestore_cleanup_service.dart
// Utility to clear Firestore database for development

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCleanupService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Clear all collections from Firestore
  static Future<void> clearAllCollections() async {
    try {
      debugPrint('🗑️ Starting Firestore cleanup...');

      final collections = [
        'users',
        'products',
        'orders',
        'services',
        'bookings',
        'reviews',
        'categories',
        'addresses',
        'carts',
      ];

      for (final collection in collections) {
        await _clearCollection(collection);
      }

      debugPrint('✅ Firestore cleanup completed successfully');
    } catch (e) {
      debugPrint('❌ Error during cleanup: $e');
      rethrow;
    }
  }

  /// Clear a specific collection
  static Future<void> _clearCollection(String collectionName) async {
    try {
      final snapshot = await _db.collection(collectionName).get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('✓ Cleared collection: $collectionName (${snapshot.docs.length} documents)');
    } catch (e) {
      debugPrint('⚠️ Error clearing $collectionName: $e');
    }
  }

  /// Get Firestore storage info
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final collections = [
        'users',
        'products',
        'orders',
        'services',
        'bookings',
        'reviews',
        'categories',
        'addresses',
        'carts',
      ];

      int totalDocs = 0;
      final collectionInfo = <String, int>{};

      for (final collection in collections) {
        final snapshot = await _db.collection(collection).get();
        final count = snapshot.docs.length;
        collectionInfo[collection] = count;
        totalDocs += count;
      }

      return {
        'totalDocuments': totalDocs,
        'collections': collectionInfo,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Error getting storage info: $e');
      return {'error': e.toString()};
    }
  }
}

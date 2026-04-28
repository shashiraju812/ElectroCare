// lib/services/maps_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory LocationData.fromMap(Map<String, dynamic> map) => LocationData(
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
        address: map['address'] as String?,
        timestamp:
            (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}

class MapsService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  LocationData? _currentLocation;
  final bool _isLoadingLocation = false;
  String? _error;
  List<LocationData> _locationHistory = [];

  LocationData? get currentLocation => _currentLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get error => _error;
  List<LocationData> get locationHistory => _locationHistory;

  /// Get human-readable address from LatLng using geocoding
  Future<String?> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
      }
      return null;
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return null;
    }
  }

  /// Get order location history from Firestore
  Future<List<LocationData>> getOrderLocationHistory({
    required String orderId,
  }) async {
    try {
      final snapshot = await _db
          .collection('orders')
          .doc(orderId)
          .collection('tracking')
          .get();

      _locationHistory = snapshot.docs.map((doc) {
        final loc = doc.data()['location'] as Map<String, dynamic>?;
        return LocationData(
          latitude: (loc?['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (loc?['longitude'] as num?)?.toDouble() ?? 0.0,
          address: loc?['address'] as String?,
          timestamp:
              (doc.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      notifyListeners();
      return _locationHistory;
    } catch (e) {
      debugPrint('Location history error: $e');
      return [];
    }
  }

  /// Save a location update for an order (for service providers)
  Future<void> trackOrderLocation({
    required String orderId,
    required String serviceProviderId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final locationData = LocationData(
        latitude: latitude,
        longitude: longitude,
        address: address,
        timestamp: DateTime.now(),
      );

      await _db
          .collection('orders')
          .doc(orderId)
          .collection('tracking')
          .add({
        'serviceProviderId': serviceProviderId,
        'location': locationData.toMap(),
        'timestamp': Timestamp.fromDate(locationData.timestamp),
      });

      _currentLocation = locationData;
      notifyListeners();
    } catch (e) {
      _error = 'Tracking error: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Simple approximation (not haversine — avoids dart:math import issue)
    final dlat = (lat2 - lat1).abs();
    final dlon = (lon2 - lon1).abs();
    return (dlat + dlon) * 111.0; // rough km
  }
}

// models/customer_model.dart
// Customer model for app users

import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';
import 'user_role.dart';

class CustomerModel extends UserModel {
  final List<String> favoriteProducts;
  final List<String> addresses;
  final String? defaultAddressId;
  final double walletBalance;
  final int totalOrders;
  final double averageRating;
  final List<String> recentSearches;
  final bool notificationsEnabled;
  final bool newsletter;

  const CustomerModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.createdAt,
    super.profileImageUrl,
    super.isActive = true,
    super.isVerified = false,
    super.address,
    super.lastSeen,
    this.favoriteProducts = const [],
    this.addresses = const [],
    this.defaultAddressId,
    this.walletBalance = 0.0,
    this.totalOrders = 0,
    this.averageRating = 0.0,
    this.recentSearches = const [],
    this.notificationsEnabled = true,
    this.newsletter = false,
  }) : super(
    role: UserRole.user,
  );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'favoriteProducts': favoriteProducts,
      'addresses': addresses,
      'defaultAddressId': defaultAddressId,
      'walletBalance': walletBalance,
      'totalOrders': totalOrders,
      'averageRating': averageRating,
      'recentSearches': recentSearches,
      'notificationsEnabled': notificationsEnabled,
      'newsletter': newsletter,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
      favoriteProducts: List<String>.from(map['favoriteProducts'] ?? []),
      addresses: List<String>.from(map['addresses'] ?? []),
      defaultAddressId: map['defaultAddressId'],
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      recentSearches: List<String>.from(map['recentSearches'] ?? []),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      newsletter: map['newsletter'] ?? false,
    );
  }

  void addFavorite(String productId) {
    if (!favoriteProducts.contains(productId)) {
      favoriteProducts.add(productId);
    }
  }

  void removeFavorite(String productId) {
    favoriteProducts.remove(productId);
  }

  bool isFavorite(String productId) => favoriteProducts.contains(productId);

  @override
  CustomerModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    bool? isActive,
    bool? isVerified,
    double? rating,
    int? totalJobs,
    String? address,
    DateTime? lastSeen,
    List<String>? favoriteProducts,
    List<String>? addresses,
    String? defaultAddressId,
    double? walletBalance,
    int? totalOrders,
    double? averageRating,
    List<String>? recentSearches,
    bool? notificationsEnabled,
    bool? newsletter,
  }) {
    return CustomerModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      address: address ?? this.address,
      createdAt: createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      addresses: addresses ?? this.addresses,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      walletBalance: walletBalance ?? this.walletBalance,
      totalOrders: totalOrders ?? this.totalOrders,
      averageRating: averageRating ?? this.averageRating,
      recentSearches: recentSearches ?? this.recentSearches,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      newsletter: newsletter ?? this.newsletter,
    );
  }
}

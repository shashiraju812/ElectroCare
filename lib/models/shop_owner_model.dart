// models/shop_owner_model.dart
// Shop Owner model for business users

import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';
import 'user_role.dart';

class ShopOwnerModel extends UserModel {
  final String shopName;
  final String? shopDescription;
  final String? shopImageUrl;
  final List<String> shopCategories;
  final String? shopAddress;
  final String? shopPhone;
  final String? businessLicense;
  final bool isVerifiedBusiness;
  final double shopRating;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final List<String> bankDetails;
  final bool acceptingOrders;
  final Map<String, bool> operatingHours;
  final List<String> serviceAreas;

  const ShopOwnerModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required this.shopName,
    required super.createdAt,
    super.profileImageUrl,
    super.isActive = true,
    super.isVerified = false,
    super.address,
    super.lastSeen,
    this.shopDescription,
    this.shopImageUrl,
    this.shopCategories = const [],
    this.shopAddress,
    this.shopPhone,
    this.businessLicense,
    this.isVerifiedBusiness = false,
    this.shopRating = 0.0,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.bankDetails = const [],
    this.acceptingOrders = true,
    this.operatingHours = const {},
    this.serviceAreas = const [],
  }) : super(
    role: UserRole.owner,
    rating: 0.0,
    totalJobs: totalOrders,
  );

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'shopName': shopName,
      'shopDescription': shopDescription,
      'shopImageUrl': shopImageUrl,
      'shopCategories': shopCategories,
      'shopAddress': shopAddress,
      'shopPhone': shopPhone,
      'businessLicense': businessLicense,
      'isVerifiedBusiness': isVerifiedBusiness,
      'shopRating': shopRating,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'bankDetails': bankDetails,
      'acceptingOrders': acceptingOrders,
      'operatingHours': operatingHours,
      'serviceAreas': serviceAreas,
    };
  }

  factory ShopOwnerModel.fromMap(Map<String, dynamic> map) {
    return ShopOwnerModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      shopName: map['shopName'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
      shopDescription: map['shopDescription'],
      shopImageUrl: map['shopImageUrl'],
      shopCategories: List<String>.from(map['shopCategories'] ?? []),
      shopAddress: map['shopAddress'],
      shopPhone: map['shopPhone'],
      businessLicense: map['businessLicense'],
      isVerifiedBusiness: map['isVerifiedBusiness'] ?? false,
      shopRating: (map['shopRating'] ?? 0.0).toDouble(),
      totalProducts: map['totalProducts'] ?? 0,
      totalOrders: map['totalOrders'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      bankDetails: List<String>.from(map['bankDetails'] ?? []),
      acceptingOrders: map['acceptingOrders'] ?? true,
      operatingHours: Map<String, bool>.from(map['operatingHours'] ?? {}),
      serviceAreas: List<String>.from(map['serviceAreas'] ?? []),
    );
  }

  @override
  ShopOwnerModel copyWith({
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
    String? shopName,
    String? shopDescription,
    String? shopImageUrl,
    List<String>? shopCategories,
    String? shopAddress,
    String? shopPhone,
    String? businessLicense,
    bool? isVerifiedBusiness,
    double? shopRating,
    int? totalProducts,
    int? totalOrders,
    double? totalRevenue,
    List<String>? bankDetails,
    bool? acceptingOrders,
    Map<String, bool>? operatingHours,
    List<String>? serviceAreas,
  }) {
    return ShopOwnerModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      shopName: shopName ?? this.shopName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      address: address ?? this.address,
      createdAt: createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      shopDescription: shopDescription ?? this.shopDescription,
      shopImageUrl: shopImageUrl ?? this.shopImageUrl,
      shopCategories: shopCategories ?? this.shopCategories,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      businessLicense: businessLicense ?? this.businessLicense,
      isVerifiedBusiness: isVerifiedBusiness ?? this.isVerifiedBusiness,
      shopRating: shopRating ?? this.shopRating,
      totalProducts: totalProducts ?? this.totalProducts,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      bankDetails: bankDetails ?? this.bankDetails,
      acceptingOrders: acceptingOrders ?? this.acceptingOrders,
      operatingHours: operatingHours ?? this.operatingHours,
      serviceAreas: serviceAreas ?? this.serviceAreas,
    );
  }
}

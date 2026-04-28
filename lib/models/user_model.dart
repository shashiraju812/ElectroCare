// models/user_model.dart
// Firestore-ready model with toMap/fromMap

import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImageUrl;
  final bool isActive;
  final bool isVerified;
  final double rating;
  final int totalJobs;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastSeen;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.profileImageUrl,
    this.isActive = true,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalJobs = 0,
    this.address,
    this.lastSeen,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get isProvider => role == UserRole.provider;
  bool get isOwner => role == UserRole.owner;
  bool get isCustomer => role == UserRole.user;

  // ── Firestore Serialization ──────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'isVerified': isVerified,
      'rating': rating,
      'totalJobs': totalJobs,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.user,
      ),
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalJobs: map['totalJobs'] ?? 0,
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  UserModel copyWith({
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
  }) {
    return UserModel(
      uid: uid,
      role: role,
      createdAt: createdAt,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      address: address ?? this.address,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

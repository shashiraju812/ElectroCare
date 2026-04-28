// lib/features/profile/data/models/profile_model.dart
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.address,
    required super.initials,
    required super.isVerified,
    required super.rating,
    required super.totalJobs,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return ProfileModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
      initials: map['initials'] ?? '',
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalJobs: map['totalJobs'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      initials: entity.initials,
      isVerified: entity.isVerified,
      rating: entity.rating,
      totalJobs: entity.totalJobs,
    );
  }
}

// lib/features/profile/domain/entities/profile_entity.dart

class ProfileEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String initials;
  final bool isVerified;
  final double rating;
  final int totalJobs;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.initials,
    required this.isVerified,
    required this.rating,
    required this.totalJobs,
  });

  ProfileEntity copyWith({
    String? name,
    String? phone,
    String? address,
  }) {
    return ProfileEntity(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      initials: initials,
      isVerified: isVerified,
      rating: rating,
      totalJobs: totalJobs,
    );
  }
}

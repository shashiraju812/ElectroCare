enum UserRole { user, owner, provider }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Customer';
      case UserRole.owner:
        return 'Shop Owner';
      case UserRole.provider:
        return 'Service Provider';
    }
  }
}

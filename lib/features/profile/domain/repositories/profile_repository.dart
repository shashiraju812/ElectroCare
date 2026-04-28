// lib/features/profile/domain/repositories/profile_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, ProfileEntity?>> getProfile(String userId);
  Future<Either<Failure, void>> updateProfile(ProfileEntity profile);
}

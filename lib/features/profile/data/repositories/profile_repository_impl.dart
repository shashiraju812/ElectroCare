// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProfileEntity?>> getProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(ProfileEntity profile) async {
    try {
      final model = ProfileModel.fromEntity(profile);
      await remoteDataSource.updateProfile(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: $e'));
    }
  }
}

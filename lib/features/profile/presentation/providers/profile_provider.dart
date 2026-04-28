// lib/features/profile/presentation/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/profile_remote_datasource.dart';

// DataSource Provider
final profileRemoteDataSourceProvider = Provider<IProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl();
});

// Repository Provider
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

// UseCase Provider
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repo);
});

// State Provider (Notifier)
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity?>> {
  final IProfileRepository repository;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileNotifier({
    required this.repository,
    required this.updateProfileUseCase,
  }) : super(const AsyncValue.loading());

  Future<void> fetchProfile(String userId) async {
    state = const AsyncValue.loading();
    final result = await repository.getProfile(userId);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? address,
  }) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      name: name,
      phone: phone,
      address: address,
    );

    state = const AsyncValue.loading();
    final result = await updateProfileUseCase(updatedProfile);
    
    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        // Reset to original data after error so UI can recover
        state = AsyncValue.data(currentProfile);
      },
      (_) => state = AsyncValue.data(updatedProfile),
    );
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileEntity?>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  final updateUseCase = ref.watch(updateProfileUseCaseProvider);
  return ProfileNotifier(
    repository: repo,
    updateProfileUseCase: updateUseCase,
  );
});

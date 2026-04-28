// lib/features/cart/presentation/providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart'; // Import sharedPreferencesProvider
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/datasources/cart_local_datasource.dart';

// DataSource Provider
final cartLocalDataSourceProvider = Provider<ICartLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CartLocalDataSourceImpl(sharedPreferences: prefs);
});

// Repository Provider
final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  final localDataSource = ref.watch(cartLocalDataSourceProvider);
  return CartRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Provider
final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return AddToCartUseCase(repo);
});

// State Provider (Notifier)
class CartNotifier extends StateNotifier<AsyncValue<List<CartItemEntity>>> {
  final ICartRepository repository;
  final AddToCartUseCase addToCartUseCase;

  CartNotifier({
    required this.repository,
    required this.addToCartUseCase,
  }) : super(const AsyncValue.loading());

  Future<void> fetchCart() async {
    state = const AsyncValue.loading();
    final result = await repository.getCartItems();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (items) => state = AsyncValue.data(items),
    );
  }

  Future<void> addItem(CartItemEntity item) async {
    final result = await addToCartUseCase(item);
    result.fold(
      (failure) => throw failure.message,
      (_) => fetchCart(), // Refresh state after adding
    );
  }

  Future<void> removeItem(String itemId) async {
    final result = await repository.removeFromCart(itemId);
    result.fold(
      (failure) => throw failure.message,
      (_) => fetchCart(),
    );
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, AsyncValue<List<CartItemEntity>>>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  final addUseCase = ref.watch(addToCartUseCaseProvider);
  return CartNotifier(
    repository: repo,
    addToCartUseCase: addUseCase,
  )..fetchCart(); // Fetch cart on initialization
});

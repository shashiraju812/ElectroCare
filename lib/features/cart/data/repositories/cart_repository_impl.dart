// lib/features/cart/data/repositories/cart_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements ICartRepository {
  final ICartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    try {
      final items = await localDataSource.getCartItems();
      return Right(items);
    } catch (e) {
      return Left(CacheFailure('Failed to load cart: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(CartItemEntity item) async {
    try {
      final items = await localDataSource.getCartItems();
      final index = items.indexWhere((i) => i.productId == item.productId);
      
      if (index != -1) {
        items[index] = CartItemModel.fromEntity(
          items[index].copyWith(quantity: items[index].quantity + item.quantity)
        );
      } else {
        items.add(CartItemModel.fromEntity(item));
      }
      
      await localDataSource.cacheCartItems(items);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add to cart: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String itemId) async {
    try {
      final items = await localDataSource.getCartItems();
      items.removeWhere((i) => i.id == itemId);
      await localDataSource.cacheCartItems(items);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove from cart: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await localDataSource.cacheCartItems([]);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cart: $e'));
    }
  }
}

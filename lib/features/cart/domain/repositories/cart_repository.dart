// lib/features/cart/domain/repositories/cart_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class ICartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCartItems();
  Future<Either<Failure, void>> addToCart(CartItemEntity item);
  Future<Either<Failure, void>> removeFromCart(String itemId);
  Future<Either<Failure, void>> clearCart();
}

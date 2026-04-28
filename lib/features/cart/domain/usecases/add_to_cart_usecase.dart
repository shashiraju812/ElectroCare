// lib/features/cart/domain/usecases/add_to_cart_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<void, CartItemEntity> {
  final ICartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CartItemEntity item) async {
    // Business rule: Quantity must be greater than 0
    if (item.quantity <= 0) {
      return const Left(ValidationFailure('Quantity must be at least 1'));
    }
    
    // Business rule: Maximum 10 items of the same product
    if (item.quantity > 10) {
      return const Left(ValidationFailure('Maximum 10 items allowed per product'));
    }

    return await repository.addToCart(item);
  }
}

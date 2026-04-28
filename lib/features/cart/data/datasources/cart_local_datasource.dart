// lib/features/cart/data/datasources/cart_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

abstract class ICartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> cacheCartItems(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements ICartLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const CACHED_CART = 'CACHED_CART';

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final jsonString = sharedPreferences.getString(CACHED_CART);
    if (jsonString != null) {
      final List decoded = json.decode(jsonString);
      return decoded.map((item) => CartItemModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> cacheCartItems(List<CartItemModel> items) {
    final jsonString = json.encode(items.map((item) => item.toJson()).toList());
    return sharedPreferences.setString(CACHED_CART, jsonString);
  }
}

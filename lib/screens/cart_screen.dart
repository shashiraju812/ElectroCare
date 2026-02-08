// screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../cart_data.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: CartData.items.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : ListView.builder(
              itemCount: CartData.items.length,
              itemBuilder: (context, index) {
                final item = CartData.items[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.electrical_services),
                    title: Text(item["name"]!),
                    subtitle: Text(item["price"]!),
                  ),
                );
              },
            ),
    );
  }
}

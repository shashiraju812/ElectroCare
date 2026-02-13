// screens/product_details_screen.dart
import 'package:flutter/material.dart';
import '../cart_data.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String name;
  final String price;
  final String image;

  const ProductDetailsScreen({
    super.key,
    required this.name,
    required this.price,
    required this.image,
  });

  void addToCart(BuildContext context) {
    CartData.items.add({
      "name": name,
      "price": price,
      "qty": 1,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(image, height: 150),
            const SizedBox(height: 20),
            Text(name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(price, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => addToCart(context),
              child: const Text("Add to Cart"),
            ),
          ],
        ),
      ),
    );
  }
}

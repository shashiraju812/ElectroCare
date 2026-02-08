// screens/product_screen.dart
import 'package:flutter/material.dart';
import '../cart_data.dart';
import 'cart_screen.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: const [
          ProductCard(name: "LED Bulb", price: "₹120"),
          ProductCard(name: "Switch Board", price: "₹250"),
          ProductCard(name: "Wire (1m)", price: "₹40"),
          ProductCard(name: "Extension Box", price: "₹350"),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.electrical_services),
        title: Text(name),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: () => addToCart(context),
          child: const Text("Buy"),
        ),
      ),
    );
  }
}

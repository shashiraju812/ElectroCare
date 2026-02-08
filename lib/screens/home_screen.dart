// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ElectroCare"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Welcome",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: HomeGrid()),
          ],
        ),
      ),
    );
  }
}

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        HomeCard(
          title: "Products",
          icon: Icons.electrical_services,
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductScreen(),
              ),
            );
          },
        ),
        const HomeCard(title: "Services", icon: Icons.build),
        const HomeCard(title: "Orders", icon: Icons.shopping_cart),
        const HomeCard(title: "Profile", icon: Icons.person),
      ],
    );
  }
}

class HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function(BuildContext)? onTap;

  const HomeCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => onTap?.call(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

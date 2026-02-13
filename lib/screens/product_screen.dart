// screens/product_screen.dart
import 'package:flutter/material.dart';
import '../cart_data.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  final List<Map<String, String>> allProducts = [
    {
      "name": "LED Bulb",
      "price": "₹120",
      "image": "https://via.placeholder.com/100?text=Bulb"
    },
    {
      "name": "Switch Board",
      "price": "₹250",
      "image": "https://via.placeholder.com/100?text=Switch"
    },
    {
      "name": "Wire (1m)",
      "price": "₹40",
      "image": "https://via.placeholder.com/100?text=Wire"
    },
    {
      "name": "Extension Box",
      "price": "₹350",
      "image": "https://via.placeholder.com/100?text=Box"
    },
  ];

  List<Map<String, String>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = allProducts;
  }

  void searchProducts(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((product) =>
              product["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addToCart(BuildContext context, String name, String price) {
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
      appBar: AppBar(title: const Text("Products")),
      body: Column(
        children: [

          // Search bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          name: product["name"]!,
                          price: product["price"]!,
                          image: product["image"]!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Image.network(
                            product["image"]!,
                            height: 60,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            product["name"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),

                          Text(product["price"]!),

                          const SizedBox(height: 8),

                          ElevatedButton(
                            onPressed: () => addToCart(
                              context,
                              product["name"]!,
                              product["price"]!,
                            ),
                            child: const Text("Buy"),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

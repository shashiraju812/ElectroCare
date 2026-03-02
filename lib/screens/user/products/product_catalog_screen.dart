import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../services/auth_service.dart';

import 'product_details_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  String _searchQuery = "";

  void _addToCart(BuildContext context, Product product) {
    Provider.of<CartService>(context, listen: false).addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A237E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Added to Cart!",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _quickBuyNow(BuildContext context, Product product) async {
    final orderService = Provider.of<OrderService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final singleItem = CartItem(product: product, quantity: 1);
    await orderService.placeOrder(authService.userName ?? "Customer", [
      singleItem,
    ], product.price);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F5E9),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "ఆర్డర్ అయింది! | ऑर्डर हो गया!\nOrder Placed! 🎉",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "₹${product.price.toStringAsFixed(0)} - ${product.name}",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.done),
                  label: const Text("OK, Continue"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final products = productService.searchProducts(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Text(
          '🛒 Products',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "🔍  Search products...",
                hintStyle: GoogleFonts.outfit(fontSize: 15),
                filled: true,
                fillColor: const Color(0xFFF0F4FF),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No products found",
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  product: product,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  ),
                  onAddToCart: () => _addToCart(context, product),
                  onBuyNow: () => _quickBuyNow(context, product),
                  index: index,
                );
              },
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final int index;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFFF0F4FF),
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, e, s) => const Center(
                    child: Icon(
                      Icons.electrical_services,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    Text(
                      product.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Text(
                      "₹${product.price.toStringAsFixed(0)}",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange[800],
                      ),
                    ),
                    const Spacer(),
                    // Action buttons side by side
                    Row(
                      children: [
                        // Cart icon button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onAddToCart,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 34),
                              foregroundColor: const Color(0xFF1A237E),
                              side: const BorderSide(
                                color: Color(0xFF1A237E),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Buy Now button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: onBuyNow,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 34),
                              backgroundColor: Colors.orange[700],
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Buy Now",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.08),
    );
  }
}

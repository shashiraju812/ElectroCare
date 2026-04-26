// screens/user/products/product_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/cached_product_image.dart';
import '../cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isBuying = false;

  void _addToCart() {
    Provider.of<CartService>(context, listen: false).addToCart(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Added to Cart! 🛒",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: Text(
                "VIEW",
                style: GoogleFonts.outfit(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _buyNow() async {
    setState(() => _isBuying = true);
    final orderService = Provider.of<OrderService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    // Place a direct single-item order
    final singleItem = CartItem(product: widget.product, quantity: 1);
    await orderService.placeOrder(
      userId: authService.userId ?? 'guest',
      cartItems: [singleItem],
      address: 'Default Address',
    );

    if (!mounted) return;
    setState(() => _isBuying = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F5E9),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "ఆర్డర్ అయింది! | ऑर्डर हो गया!\nOrder Placed! 🎉",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${widget.product.name}\n₹${widget.product.price.toStringAsFixed(0)}",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("Back to Home"),
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
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Hero image with back button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: Container(
                  color: const Color(0xFFF0F4FF),
                  padding: const EdgeInsets.all(30),
                  child: CachedProductImage(
                    imageUrl: product.imageUrl,
                    height: 300,
                    fit: BoxFit.contain,
                    backgroundColor: const Color(0xFFF0F4FF),
                  ),
                ),
              ),
            ),
          ),

          // Product info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "🔌 ${product.category}",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Product name
                  Text(
                    product.name,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                      height: 1.2,
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 10),

                  // Price & Stock row
                  Row(
                    children: [
                      Text(
                        "₹${product.price.toStringAsFixed(0)}",
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[700],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "In Stock",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(
                        4,
                        (_) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const Icon(
                        Icons.star_half,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "4.5  (120 Reviews)",
                        style: GoogleFonts.outfit(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Description
                  Text(
                    "📋 Product Details",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feature chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _featureChip(Icons.verified, "ISI Certified"),
                      _featureChip(Icons.replay, "Easy Returns"),
                      _featureChip(Icons.local_shipping, "Fast Delivery"),
                      _featureChip(Icons.support_agent, "Customer Support"),
                    ],
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ADD TO CART button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: Text(
                  "Add to Cart",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A237E),
                  side: const BorderSide(color: Color(0xFF1A237E), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // BUY NOW button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isBuying ? null : _buyNow,
                icon: _isBuying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.flash_on, size: 20),
                label: Text(
                  _isBuying ? "Placing..." : "Buy Now",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, duration: 350.ms, curve: Curves.easeOut),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1A237E)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

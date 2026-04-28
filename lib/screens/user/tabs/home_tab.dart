// screens/user/tabs/home_tab.dart
// ─────────────────────────────────────────────────────────────────
// UPGRADED: StatefulWidget with real working search, cart badge,
// category filter chips, and live product grid
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/product_service.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../models/product_model.dart';
import '../../../models/cart_model.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/cached_product_image.dart';
import '../cart_screen.dart';
import '../notifications_screen.dart';
import '../products/product_catalog_screen.dart';
import '../products/product_details_screen.dart';
import '../services/service_booking_screen.dart';
import '../../../widgets/ai_assistant_fab.dart';


class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productService = context.watch<ProductService>();
    // Tell service about current search query, then read filtered results
    final products = productService.filteredProducts
        .where((p) => _searchQuery.isEmpty ||
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    final cartService = context.watch<CartService>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Electro',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Care',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentAmber,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textBlack),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          // Cart with badge count
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textBlack),
                onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (cartService.itemCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartService.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. WORKING Search Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search bulbs, fans, wires...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ── Trending Keywords (Smart Search) ──────────────────
            if (_searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Trending: ', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                      _buildTrendingChip('Ceiling Fan'),
                      _buildTrendingChip('LED Bulb'),
                      _buildTrendingChip('Copper Wire'),
                      _buildTrendingChip('Switch'),
                    ],
                  ),
                ),
              ),

            // ── Search Results Mode ───────────────────────────────
            if (_searchQuery.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  '${products.length} results for "$_searchQuery"',
                  style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 13),
                ),
              ),
              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No products found', style: TextStyle(color: Colors.grey)),
                    ]),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.75,
                    crossAxisSpacing: 16, mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _buildProductCard(context, products[i]),
                ),
              const SizedBox(height: 24),
            ] else ...[
              // ── 2. Promo Banner ───────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 20, offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30, bottom: -30,
                        child: Icon(Icons.bolt, size: 200, color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      // Glassmorphism Overlay
                      Positioned(
                        right: 20, top: 20,
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.glassGradient,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentAmber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('LIMITED OFFER',
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 12),
                            Text('Summer Sale', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('Up to 40% off on premium\nCooling Appliances',
                              style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, curve: Curves.easeOutQuad),

              const SizedBox(height: 24),

              // ── 3. Quick Actions ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _buildQuickAction(context, icon: Icons.bolt, label: 'Book Electrician',
                        color: AppColors.primaryBlue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceBookingScreen())))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction(context, icon: Icons.shopping_bag_outlined, label: 'Browse Products',
                        color: AppColors.accentAmber, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductCatalogScreen())))),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 4. Categories ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductCatalogScreen())),
                      child: Text('See All', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    const _CategoryItem(label: 'Electrical', icon: Icons.electrical_services),
                    const _CategoryItem(label: 'Lighting', icon: Icons.light),
                    const _CategoryItem(label: 'Wiring', icon: Icons.cable),
                    const _CategoryItem(label: 'Tools', icon: Icons.build),
                    const _CategoryItem(label: 'Appliances', icon: Icons.air),
                    const _CategoryItem(label: 'Protection', icon: Icons.security),
                  ].animate(interval: 100.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                ),
              ),

              const SizedBox(height: 24),

              // ── 5. Featured Products Grid ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Featured Products', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductCatalogScreen())),
                      child: Text('See All', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (productService.isLoading)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.72,
                    crossAxisSpacing: 16, mainAxisSpacing: 16,
                  ),
                  itemCount: products.length > 4 ? 4 : products.length,
                  itemBuilder: (_, i) => _buildProductCard(context, products[i]),
                ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      floatingActionButton: const AiAssistantFab(),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark))),
          Icon(Icons.arrow_forward_ios, size: 14, color: color),
        ]),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 110, width: double.infinity,
                color: const Color(0xFFF0F4FF),
                padding: const EdgeInsets.all(14),
                child: CachedProductImage(
                  imageUrl: product.imageUrl,
                  height: 110,
                  fit: BoxFit.contain,
                  backgroundColor: const Color(0xFFF0F4FF),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.category, style: GoogleFonts.outfit(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textBlack, height: 1.3)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('₹${product.effectivePrice.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.orange[800])),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text('₹${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ],
                    ]),
                    const Spacer(),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<CartService>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: AppColors.primaryBlue,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              content: Text('Added to cart! 🛒', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                              duration: const Duration(seconds: 2),
                            ));
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero, minimumSize: const Size(0, 30),
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, size: 14),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final orderService = context.read<OrderService>();
                            final authSvc = context.read<AuthService>();
                            final item = CartItem(product: product, quantity: 1);
                            await orderService.placeOrder(
                              userId: authSvc.userId ?? 'guest',
                              cartItems: [item],
                              address: 'Default Address',
                            );
                            if (!mounted) return;
                            _showOrderConfirmDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, minimumSize: const Size(0, 30),
                            backgroundColor: Colors.orange[700], foregroundColor: Colors.white,
                            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Buy Now', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderConfirmDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
      content: Text('Order Placed Successfully! 🎉', textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
    ));
  }

  Widget _buildTrendingChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        setState(() => _searchQuery = label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Category Chip Widget ──────────────────────────────────────────
class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CategoryItem({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductCatalogScreen())),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 26),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textBlack, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

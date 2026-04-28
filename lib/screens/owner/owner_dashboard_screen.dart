// screens/owner/owner_dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────
// UPGRADED: Real calculated stats, Edit/Delete product buttons,
// real Top Products from OrderService, AI insights widget
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'add_product_screen.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../widgets/cached_product_image.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_translations.dart';
import '../auth/role_selection_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = context.watch<OrderService>();
    final productService = context.watch<ProductService>();
    final auth = context.read<AuthService>();

    final totalOrders = orderService.allOrders.length;
    final totalProducts = productService.allProducts.length;
    final totalSales = orderService.allOrders.fold<double>(0.0, (sum, o) => sum + o.totalAmount);
    final pendingOrders = orderService.allOrders.where((o) => o.status == OrderStatus.pending).length;

    // Top products from actual order data
    final productSaleCount = <String, int>{};
    for (final order in orderService.allOrders) {
      for (final item in order.items) {
        productSaleCount[item.productName] = (productSaleCount[item.productName] ?? 0) + item.quantity;
      }
    }
    final topProducts = productSaleCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxSales = topProducts.isEmpty ? 1 : topProducts.first.value;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Shop Dashboard', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(context, auth),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats Grid (Real data) ────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total Sales', '₹${totalSales.toStringAsFixed(0)}', Colors.blue, Icons.currency_rupee),
                _buildStatCard('Orders', '$totalOrders', Colors.orange, Icons.shopping_bag_outlined),
                _buildStatCard('Products', '$totalProducts', Colors.purple, Icons.inventory_2_outlined),
                _buildStatCard('Processing', '$pendingOrders', Colors.red, Icons.hourglass_top),
              ],
            ).animate().slideY(begin: 0.1),

            const SizedBox(height: 28),

            // ── Inventory Management ──────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Inventory', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text('Add Product', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ),
            ]),
            const SizedBox(height: 12),

            // ── Product List with Edit/Delete ─────────────────────
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productService.allProducts.length,
              itemBuilder: (_, i) {
                final product = productService.allProducts[i];
                return _buildProductManageCard(context, product, i)
                    .animate().fadeIn(delay: (i * 60).ms);
              },
            ),

            const SizedBox(height: 28),

            // ── Recent Orders ─────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Recent Orders', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              TextButton(onPressed: () {}, child: Text('View All', style: GoogleFonts.outfit(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
            ]),
            if (orderService.allOrders.isEmpty)
              _buildEmpty('No orders yet')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderService.allOrders.take(5).length,
                itemBuilder: (_, i) {
                  final order = orderService.allOrders[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0, color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlue),
                      ),
                      title: Text('Order #${order.id.length > 4 ? order.id.substring(order.id.length - 4) : order.id}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      subtitle: Text('${order.items.length} item(s) • ₹${order.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 12)),
                      trailing: _buildStatusBadge(order.status),
                    ),
                  ).animate().fadeIn(delay: (i * 80).ms);
                },
              ),

            const SizedBox(height: 28),

            // ── Top Products (Real data / placeholder if empty) ───
            Text('Top Performing Products', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            if (topProducts.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!)),
                child: Center(child: Text('Place some orders to see top products',
                  style: GoogleFonts.outfit(color: Colors.grey))),
              )
            else
              ...topProducts.take(5).map((entry) => _buildTopProductBar(
                entry.key, entry.value, entry.value / maxSales))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
        label: Text('Add Product', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ── Product Management Card with Edit + Delete ────────────────────
  Widget _buildProductManageCard(BuildContext context, Product product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Product thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 52, height: 52, color: const Color(0xFFF0F4FF),
              padding: const EdgeInsets.all(6),
              child: CachedProductImage(
                imageUrl: product.imageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                backgroundColor: const Color(0xFFF0F4FF),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('₹${product.effectivePrice.toStringAsFixed(0)} • Stock: ${product.stock}',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
              if (product.stock < 10)
                Text('⚠️ Low stock!', style: GoogleFonts.outfit(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
            ]),
          ),
          // Edit + Delete buttons
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (action) {
              if (action == 'edit') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AddProductScreen(existingProduct: product),
                ));
              } else if (action == 'delete') {
                _confirmDelete(context, product);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit',
                child: Row(children: [const Icon(Icons.edit_outlined, size: 18, color: Colors.blue), const SizedBox(width: 8),
                  Text('Edit', style: GoogleFonts.outfit())])),
              PopupMenuItem(value: 'delete',
                child: Row(children: [const Icon(Icons.delete_outline, size: 18, color: Colors.red), const SizedBox(width: 8),
                  Text('Delete', style: GoogleFonts.outfit(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Product?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: Text('Are you sure you want to delete "${product.name}"?\nThis cannot be undone.',
        style: GoogleFonts.outfit()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ProductService>().deleteProduct(product.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('🗑️ Product deleted',
                  style: GoogleFonts.outfit(color: Colors.white)),
                backgroundColor: Colors.red[400],
                behavior: SnackBarBehavior.floating,
              ));
            },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Delete', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  Widget _buildTopProductBar(String name, int sales, double fraction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          Text('$sales sold', style: GoogleFonts.outfit(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction, backgroundColor: Colors.grey[100],
            color: AppColors.accentAmber, minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(title, style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ]),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final color = status == OrderStatus.processing ? Colors.orange
        : status == OrderStatus.shipped ? Colors.blue : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildEmpty(String msg) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(child: Text(msg, style: GoogleFonts.outfit(color: Colors.grey))),
  );

  // ── Settings Bottom Sheet ─────────────────────────────────────
  void _showSettingsSheet(BuildContext context, AuthService auth) {
    final langService = context.read<LanguageService>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentLang = langService.currentLanguage;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Settings', style: GoogleFonts.outfit(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 20),
                // Language selector
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primaryBlue),
                  title: Text('Language', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  subtitle: Text('${currentLang.flag} ${currentLang.nativeName}',
                    style: GoogleFonts.outfit(color: AppColors.textGrey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.grey[50],
                  onTap: () {
                    Navigator.pop(ctx);
                    _showLanguagePicker(context);
                  },
                ),
                const SizedBox(height: 12),
                // Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('Logout', style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.red[50],
                  onTap: () async {
                    Navigator.pop(ctx);
                    await auth.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final langService = context.read<LanguageService>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppTranslations.tr('select_language', langService.currentCode),
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...LanguageService.supportedLanguages.map((lang) {
              final isSelected = lang.code == langService.currentCode;
              return ListTile(
                leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                title: Text(lang.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                subtitle: Text(lang.nativeName, style: GoogleFonts.outfit(color: AppColors.textGrey)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryBlue) : null,
                selected: isSelected,
                selectedTileColor: AppColors.primaryBlue.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  langService.setLanguage(lang.code);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

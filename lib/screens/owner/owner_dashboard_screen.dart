import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'add_product_screen.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../utils/app_colors.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);
    final productService = Provider.of<ProductService>(context);

    // Calculate stats
    final totalOrders = orderService.orders.length;
    final totalProducts = productService.products.length;
    final totalSales = orderService.orders.fold(
      0.0,
      (sum, order) => sum + order.totalAmount,
    );
    final pendingOrders = orderService.orders
        .where((o) => o.status.name == 'pending')
        .length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Shop Dashboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  "Total Sales",
                  "₹${totalSales.toStringAsFixed(0)}",
                  Colors.blue,
                ),
                _buildStatCard("Orders", "$totalOrders", Colors.orange),
                _buildStatCard("Products", "$totalProducts", Colors.purple),
                _buildStatCard("Pending", "$pendingOrders", Colors.red),
              ],
            ).animate().slideY(begin: 0.1),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Orders",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "View All",
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (orderService.orders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "No orders yet.",
                    style: GoogleFonts.outfit(color: AppColors.textGrey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderService.orders.take(5).length,
                itemBuilder: (context, index) {
                  final order = orderService.orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withValues(
                          alpha: 0.1,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      title: Text(
                        "Order #${order.id.substring(order.id.length - 4)}",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${order.items.length} items • ₹${order.totalAmount}",
                        style: GoogleFonts.outfit(color: AppColors.textGrey),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "New",
                          style: GoogleFonts.outfit(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms);
                },
              ),

            const SizedBox(height: 30),

            // Sales Trends (New Intelligent Feature)
            Text(
              "Top Performing Products",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 15),

            _buildTrendingProduct("LED Bulb (9W)", 45, 0.8),
            _buildTrendingProduct("Modular Switch", 32, 0.6),
            _buildTrendingProduct("Ceiling Fan", 15, 0.4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        label: Text(
          "Add Product",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTrendingProduct(String name, int sales, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              Text(
                "$sales sold",
                style: GoogleFonts.outfit(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[100],
              color: AppColors.accentAmber,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: GoogleFonts.outfit(color: AppColors.textGrey)),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

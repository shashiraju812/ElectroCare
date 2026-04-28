// lib/features/profile/presentation/widgets/profile_orders.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/order_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../../screens/order_tracking_screen.dart';

class ProfileOrders extends StatelessWidget {
  final List<Order> orders;

  const ProfileOrders({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("📦 My Orders"),
            const SizedBox(height: 10),
            orders.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 54,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No orders yet",
                          style: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: orders
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => _orderCard(context, e.value, e.key))
                        .toList(),
                  ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textBlack,
      ),
    );
  }

  Widget _orderCard(BuildContext context, Order order, int index) {
    final statusColor = order.status == OrderStatus.processing
        ? Colors.orange
        : order.status == OrderStatus.shipped
        ? Colors.blue
        : Colors.green;
    
    final statusLabel = order.status == OrderStatus.processing
        ? "Processing"
        : order.status == OrderStatus.shipped
        ? "Shipped"
        : "Delivered";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${order.items.length} item(s)  •  ₹${order.totalAmount.toStringAsFixed(0)}",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Order #${order.id.substring(order.id.length - 5)}",
                    style: GoogleFonts.outfit(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.outfit(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms);
  }
}

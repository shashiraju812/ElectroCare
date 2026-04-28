// lib/screens/order_tracking_screen.dart
// Order tracking screen — native Flutter UI (no Google Maps SDK required)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart' as app_models;
import '../utils/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final app_models.Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.8, end: 1.2).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _shortId {
    final id = widget.order.id;
    return id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Track Order #$_shortId',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Animated Status Card ────────────────────────
            _buildStatusCard(status),
            const SizedBox(height: 16),

            // ── Tracking Timeline ───────────────────────────
            _buildTrackingTimeline(status),
            const SizedBox(height: 16),

            // ── Delivery Partner Card ───────────────────────
            _buildDeliveryPartnerCard(),
            const SizedBox(height: 16),

            // ── Order Summary ───────────────────────────────
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(app_models.OrderStatus status) {
    final isDelivered = status == app_models.OrderStatus.delivered;
    final color = isDelivered ? Colors.green : AppColors.primaryBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDelivered ? Icons.check_circle : Icons.local_shipping,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            status.label,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDelivered
                ? 'Your order has been delivered!'
                : 'Your order is on the way',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(app_models.OrderStatus status) {
    final steps = [
      _TrackingStep(
        icon: Icons.receipt_long,
        label: 'Order Placed',
        subtitle: 'Your order has been received',
        status: app_models.OrderStatus.pending,
      ),
      _TrackingStep(
        icon: Icons.inventory_2,
        label: 'Processing',
        subtitle: 'Preparing your items',
        status: app_models.OrderStatus.processing,
      ),
      _TrackingStep(
        icon: Icons.local_shipping,
        label: 'Shipped',
        subtitle: 'Out for delivery',
        status: app_models.OrderStatus.shipped,
      ),
      _TrackingStep(
        icon: Icons.home,
        label: 'Delivered',
        subtitle: 'Package delivered',
        status: app_models.OrderStatus.delivered,
      ),
    ];

    final currentIndex = steps.indexWhere((s) => s.status == status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone = i <= currentIndex;
            final isActive = i == currentIndex;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.primaryBlue
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: isActive
                            ? Border.all(
                                color: AppColors.primaryBlue,
                                width: 3,
                              )
                            : null,
                      ),
                      child: Icon(
                        isDone ? Icons.check : step.icon,
                        color: isDone ? Colors.white : Colors.grey,
                        size: 20,
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 36,
                        color: isDone
                            ? AppColors.primaryBlue
                            : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: GoogleFonts.outfit(
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isDone
                                ? AppColors.textDark
                                : Colors.grey,
                          ),
                        ),
                        Text(
                          step.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryPartnerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Partner',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Rajesh Kumar',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      ' 4.8 · 1,240 deliveries',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone, color: AppColors.primaryBlue),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName} × ${item.quantity}',
                        style: GoogleFonts.outfit(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${item.total.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${widget.order.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackingStep {
  final IconData icon;
  final String label;
  final String subtitle;
  final app_models.OrderStatus status;

  _TrackingStep({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.status,
  });
}

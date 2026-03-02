import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/product_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../utils/app_colors.dart';
import '../../auth/role_selection_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final orderService = Provider.of<OrderService>(context);
    final orders = orderService.orders;
    final name = auth.userName ?? "Guest";
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          // ─── Header ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Avatar with initials
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials.isEmpty ? '👤' : initials,
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 400.ms),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Trilingual welcome
                  Text(
                    "నమస్కారం • नमस्ते • Welcome!",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statChip("${orders.length}", "Orders"),
                      const SizedBox(width: 16),
                      _statChip("0", "Bookings"),
                      const SizedBox(width: 16),
                      _statChip("⭐ 4.8", "Rating"),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 20)),

          // ─── Account Info ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("👤 Account  •  ఖాతా"),
                  const SizedBox(height: 10),
                  _infoCard([
                    _infoRow(Icons.person, "Name  •  పేరు", name),
                    const Divider(height: 1),
                    _infoRow(Icons.phone, "Phone  •  ఫోన్", "9876543210"),
                    const Divider(height: 1),
                    _infoRow(
                      Icons.email_outlined,
                      "Email  •  ఇమెయిల్",
                      "demo@electrocare.app",
                    ),
                  ]),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 20)),

          // ─── Recent Orders ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("📦 My Orders  •  నా ఆర్డర్లు"),
                  const SizedBox(height: 10),
                  orders.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
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
                                ),
                              ),
                              Text(
                                "ఇంకా ఆర్డర్లు లేవు  •  अभी कोई ऑर्डर नहीं",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[400],
                                  fontSize: 12,
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
                              .map((e) => _orderCard(e.value, e.key))
                              .toList(),
                        ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 20)),

          // ─── Settings / Options ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("⚙️ Settings  •  సెట్టింగ్‌లు"),
                  const SizedBox(height: 10),
                  _infoCard([
                    _settingRow(
                      Icons.language,
                      "App Language  •  భాష",
                      "English / తెలుగు / हिंदी",
                      onTap: () => _showLanguageSheet(context),
                    ),
                    const Divider(height: 1),
                    _settingRow(
                      Icons.notifications_outlined,
                      "Notifications  •  నోటిఫికేషన్లు",
                      "On",
                    ),
                    const Divider(height: 1),
                    _settingRow(
                      Icons.info_outline,
                      "App Version  •  యాప్ వెర్షన్",
                      "v1.0.0",
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        auth.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoleSelectionScreen(),
                          ),
                          (_) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        "Logout  •  లాగ్ అవుట్  •  लॉग आउट",
                        style: GoogleFonts.outfit(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Language  •  భాష ఎంచుకోండి",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _langOption(ctx, "🇬🇧", "English", "English"),
            _langOption(ctx, "🇮🇳", "తెలుగు", "Telugu"),
            _langOption(ctx, "🇮🇳", "हिंदी", "Hindi"),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _langOption(
    BuildContext ctx,
    String flag,
    String label,
    String sublabel,
  ) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        label,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        sublabel,
        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(Icons.check_circle, color: AppColors.primaryGreen),
      onTap: () => Navigator.pop(ctx),
    );
  }

  Widget _orderCard(Order order, int index) {
    final statusColor = order.status == OrderStatus.processing
        ? Colors.orange
        : order.status == OrderStatus.shipped
        ? Colors.blue
        : Colors.green;
    final statusLabel = order.status == OrderStatus.processing
        ? "Processing  •  ప్రాసెసింగ్"
        : order.status == OrderStatus.shipped
        ? "Shipped  •  వెళ్ళింది"
        : "Delivered  •  వచ్చింది";

    return Container(
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
    ).animate().fadeIn(delay: (index * 60).ms);
  }

  Widget _statChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
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

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

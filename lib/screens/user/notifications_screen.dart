// screens/user/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<_NotifItem> _items = [
    _NotifItem(
      icon: Icons.local_offer_outlined,
      title: 'Summer Sale is Live!',
      subtitle: 'Up to 40% off on Cooling Appliances.',
      time: '2h ago',
      color: Colors.orange,
    ),
    _NotifItem(
      icon: Icons.check_circle_outline,
      title: 'Order Confirmed',
      subtitle: 'Your order #1042 has been confirmed.',
      time: 'Yesterday',
      color: Colors.green,
    ),
    _NotifItem(
      icon: Icons.bolt,
      title: 'Electrician Booking',
      subtitle: 'Your booking is scheduled for tomorrow 10 AM.',
      time: '2d ago',
      color: AppColors.primaryBlue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No notifications yet', style: GoogleFonts.outfit(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = _items[i];
                return Container(
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.color, size: 22),
                    ),
                    title: Text(item.title,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(item.subtitle,
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textGrey)),
                    trailing: Text(item.time,
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                  ),
                );
              },
            ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  const _NotifItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}

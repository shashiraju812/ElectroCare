// lib/screens/user/tabs/bookings_tab.dart
// ─────────────────────────────────────────────────────────────────
// UPGRADED: Uses userId not userName, shows ETA on accepted jobs,
// Cancel button for pending bookings, inProgress status color
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../models/booking_model.dart';
import '../../../services/booking_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_colors.dart';
import '../services/service_booking_screen.dart';

class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = context.watch<BookingService>();
    final auth = context.watch<AuthService>();

    // ✅ FIX: Use userId, not userName
    final userId = auth.userId ?? auth.userName ?? '';
    final userBookings = bookingService.getUserBookings(userId)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('My Bookings',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceBookingScreen())),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Book Electrician', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: userBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text('No bookings yet', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Tap the button below to book an electrician',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: userBookings.length,
              itemBuilder: (context, index) =>
                  _buildBookingCard(context, userBookings[index], index),
            ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking, int index) {
    // Status visual config using model's label getter
    final statusColor = _statusColor(booking.status);
    final statusIcon = _statusIcon(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: booking.status == BookingStatus.inProgress
            ? Border.all(color: Colors.orange, width: 1.5)
            : booking.urgency == 'high'
                ? Border.all(color: Colors.red.shade200, width: 1.5)
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: service + status badge ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.electrical_services, color: AppColors.primaryBlue, size: 20),
                ),
                const SizedBox(width: 10),
                Text(booking.serviceType,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(booking.status.label,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                ]),
              ),
            ],
          ),

          // ── Emergency badge ─────────────────────────────────────
          if (booking.urgency == 'high') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
              child: Text('🚨 Emergency Request',
                style: GoogleFonts.outfit(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],

          const SizedBox(height: 10),
          Text(booking.description, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 10),

          // ── Provider ETA (shown when accepted) ──────────────────
          if (booking.status == BookingStatus.accepted && booking.providerName != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.engineering, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${booking.providerName} is on the way!',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 13)),
                  if (booking.providerEta != null)
                    Text('ETA: ${booking.providerEta}',
                      style: GoogleFonts.outfit(color: Colors.blue, fontSize: 12)),
                ])),
              ]),
            ),
            const SizedBox(height: 10),
          ],

          // ── In Progress indicator ───────────────────────────────
          if (booking.status == BookingStatus.inProgress) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const SizedBox(width: 8, height: 8,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.orange))),
                const SizedBox(width: 10),
                Text('Work in progress...', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 10),
          ],

          // ── Estimated Price ─────────────────────────────────────
          if (booking.estimatedPrice != null)
            Text('AI estimate: ₹${booking.estimatedPrice!.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w600)),

          // ── Date + Time ─────────────────────────────────────────
          const SizedBox(height: 8),
          if (booking.scheduledDate != null && booking.scheduledTime != null)
            Row(children: [
              const Icon(Icons.event, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('MMM d, yyyy').format(booking.scheduledDate!)} at ${booking.scheduledTime}',
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
            ])
          else
            Row(children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(DateFormat('MMM d, yyyy – h:mm a').format(booking.timestamp),
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            ]),

          // ── Location ────────────────────────────────────────────
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on, size: 14, color: Colors.red),
            const SizedBox(width: 6),
            Expanded(child: Text(booking.location,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]))),
          ]),

          // ── Cancel button (only for pending) ─────────────────────
          if (booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: Text('Cancel Booking', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onPressed: () => _confirmCancel(context, booking.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],

          // ── Final price (when completed) ─────────────────────────
          if (booking.status == BookingStatus.completed && booking.finalPrice != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.currency_rupee, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Text('Final charge: ₹${booking.finalPrice!.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.green)),
              ]),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.05);
  }

  void _confirmCancel(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Booking?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to cancel this booking?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<BookingService>().cancelBooking(bookingId);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Booking cancelled'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted: return Colors.blue;
      case BookingStatus.inProgress: return Colors.orange;
      case BookingStatus.completed: return Colors.green;
      case BookingStatus.cancelled: return Colors.red;
      case BookingStatus.disputed: return Colors.purple;
      default: return Colors.orange;
    }
  }

  IconData _statusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted: return Icons.thumb_up;
      case BookingStatus.inProgress: return Icons.directions_run;
      case BookingStatus.completed: return Icons.check_circle;
      case BookingStatus.cancelled: return Icons.cancel;
      case BookingStatus.disputed: return Icons.warning_amber;
      default: return Icons.hourglass_top;
    }
  }
}

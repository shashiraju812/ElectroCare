// lib/screens/user/services/booking_tracking_screen.dart
// Real-time booking status tracker — no Google Maps required

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/booking_model.dart';
import '../../../services/booking_service.dart';
import '../../../utils/app_colors.dart';

class BookingTrackingScreen extends StatefulWidget {
  final String bookingId;
  const BookingTrackingScreen({super.key, required this.bookingId});

  @override
  State<BookingTrackingScreen> createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _pulseAnim;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _progressCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Start listening to booking updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingService>().listenToBookings();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingService>(
      builder: (context, bookingService, _) {
        final booking = bookingService.allBookings
            .where((b) => b.id == widget.bookingId)
            .firstOrNull;

        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Track Booking')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading booking details...'),
                ],
              ),
            ),
          );
        }

        return _buildTrackingView(context, booking);
      },
    );
  }

  Widget _buildTrackingView(BuildContext context, Booking booking) {
    final status = booking.status;
    final isCompleted = status == BookingStatus.completed;
    final isCancelled = status == BookingStatus.cancelled ||
        status == BookingStatus.disputed;
    final primaryColor = isCancelled
        ? Colors.red
        : isCompleted
            ? Colors.green
            : AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Booking Tracker',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.name.toUpperCase(),
              style: GoogleFonts.outfit(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusHero(booking, primaryColor, isCancelled),
            const SizedBox(height: 16),
            _buildTimeline(booking),
            const SizedBox(height: 16),
            if (booking.providerId != null && booking.providerId!.isNotEmpty)
              _buildProviderCard(booking),
            if (booking.providerId != null && booking.providerId!.isNotEmpty)
              const SizedBox(height: 16),
            _buildBookingDetails(booking),
            const SizedBox(height: 16),
            if (!isCompleted && !isCancelled)
              _buildLiveUpdateCard(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHero(
      Booking booking, Color color, bool isCancelled) {
    IconData icon;
    String title;
    String subtitle;
    switch (booking.status) {
      case BookingStatus.pending:
        icon = Icons.hourglass_top_rounded;
        title = 'Searching Electrician...';
        subtitle = 'We\'re finding the best electrician near you';
        break;
      case BookingStatus.accepted:
        icon = Icons.handshake;
        title = 'Electrician Assigned!';
        subtitle = '${booking.providerName ?? "Technician"} will arrive at your location';
        break;
      case BookingStatus.inProgress:
        icon = Icons.electrical_services;
        title = 'Work In Progress';
        subtitle = 'Your electrician is currently working on your request';
        break;
      case BookingStatus.completed:
        icon = Icons.check_circle;
        title = 'Service Complete! ✓';
        subtitle = 'Your service has been completed successfully';
        break;
      case BookingStatus.cancelled:
        icon = Icons.cancel;
        title = 'Booking Cancelled';
        subtitle = 'This booking has been cancelled';
        break;
      case BookingStatus.disputed:
        icon = Icons.report_problem;
        title = 'Under Dispute';
        subtitle = 'This booking is currently under review';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (booking.status == BookingStatus.pending)
            ScaleTransition(
              scale: _pulseAnim,
              child: _iconCircle(icon, color),
            )
          else
            _iconCircle(icon, color),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          if (booking.scheduledDate != null && booking.scheduledTime != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('MMM d').format(booking.scheduledDate!)} at ${booking.scheduledTime}',
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 52, color: Colors.white),
    );
  }

  Widget _buildTimeline(Booking booking) {
    final steps = [
      _Step(BookingStatus.pending, Icons.receipt_long, 'Request Placed',
          'Your booking has been submitted'),
      _Step(BookingStatus.accepted, Icons.handshake, 'Electrician Assigned',
          'A professional has been assigned'),
      _Step(BookingStatus.inProgress, Icons.electrical_services, 'Work Started',
          'Electrician is on site'),
      _Step(BookingStatus.completed, Icons.check_circle, 'Completed',
          'Service done successfully'),
    ];

    final currentIdx = steps.indexWhere((s) => s.status == booking.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Timeline',
              style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone =
                booking.status != BookingStatus.cancelled && i <= currentIdx;
            final isActive = i == currentIdx;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primaryBlue : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(color: AppColors.primaryBlue, width: 3)
                          : null,
                    ),
                    child: Icon(
                      isDone ? Icons.check : step.icon,
                      color: isDone ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                  ),
                  if (i < steps.length - 1)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 2,
                      height: 40,
                      color:
                          isDone ? AppColors.primaryBlue : Colors.grey.shade200,
                    ),
                ]),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.label,
                            style: GoogleFonts.outfit(
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isDone
                                  ? AppColors.textDark
                                  : Colors.grey,
                            )),
                        Text(step.subtitle,
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.grey)),
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

  Widget _buildProviderCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child:
                const Icon(Icons.person, color: AppColors.primaryBlue, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Electrician',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey)),
                Text(booking.providerName ?? 'Technician',
                    style: GoogleFonts.outfit(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                if (booking.providerEta != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('ETA: ${booking.providerEta}',
                          style: GoogleFonts.outfit(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primaryBlue),
            style: IconButton.styleFrom(
              backgroundColor:
                  AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Details',
              style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _detailRow(Icons.bolt, 'Service', booking.serviceType),
          _detailRow(Icons.description, 'Issue', booking.description,
              maxLines: 2),
          _detailRow(Icons.location_on, 'Address', booking.location),
          if (booking.estimatedPrice != null)
            _detailRow(Icons.currency_rupee, 'Estimated Cost',
                '₹${booking.estimatedPrice!.toStringAsFixed(0)}'),
          if (booking.aiCategory != null)
            _detailRow(Icons.psychology, 'AI Classified',
                '${booking.aiCategory} • ${booking.urgency ?? "Normal"} urgency'),
          _detailRow(Icons.schedule, 'Booked',
              DateFormat('MMM d, yyyy h:mm a').format(booking.timestamp)),
        ],
      ),
    );
  }

  Widget _buildLiveUpdateCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Live tracking active — this page updates automatically when your electrician accepts',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey)),
                Text(value,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _Step {
  final BookingStatus status;
  final IconData icon;
  final String label;
  final String subtitle;
  _Step(this.status, this.icon, this.label, this.subtitle);
}

// lib/screens/provider/provider_dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────
// UPGRADED: Real Ignore button, Accept with ETA input,
// Mark as In-Progress/Complete, My Jobs tab
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../models/booking_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_translations.dart';
import '../auth/role_selection_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = context.watch<BookingService>();
    final auth = context.watch<AuthService>();
    final providerId = auth.userId ?? auth.userName ?? 'provider';

    final availableJobs = bookingService.getAvailableBookings(providerId);
    final myJobs = bookingService.getProviderBookings(providerId)
        .where((b) => b.status != BookingStatus.pending)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Electrician Dashboard', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(context, auth),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.outfit(),
          indicatorColor: const Color(0xFF1A237E),
          labelColor: const Color(0xFF1A237E),
          tabs: [
            Tab(text: 'New Jobs (${availableJobs.length})'),
            Tab(text: 'My Jobs (${myJobs.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Online/Offline Toggle ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isOnline ? '🟢 You are Online' : '🔴 You are Offline',
                      style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: _isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(
                      _isOnline ? 'Receiving new job requests...' : 'Go online to start working',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (val) => setState(() => _isOnline = val),
                  activeThumbColor: Colors.green,
                  activeTrackColor: Colors.green[100],
                ),
              ],
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Available/New Jobs
                !_isOnline
                    ? _buildOfflineState()
                    : availableJobs.isEmpty
                        ? _buildEmptyState('No new jobs right now', Icons.assignment_turned_in_outlined)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: availableJobs.length,
                            itemBuilder: (_, i) => _buildAvailableJobCard(
                              context, availableJobs[i], i, providerId,
                              auth.userName ?? 'Provider',
                            ),
                          ),

                // TAB 2: My Accepted/Active Jobs
                myJobs.isEmpty
                    ? _buildEmptyState('No accepted jobs yet', Icons.work_outline)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: myJobs.length,
                        itemBuilder: (_, i) => _buildMyJobCard(context, myJobs[i], i),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Available Job Card (with WORKING Ignore + Accept) ─────────────
  Widget _buildAvailableJobCard(BuildContext context, Booking booking, int index,
      String providerId, String providerName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: service type + urgency badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                child: Text(booking.serviceType,
                  style: GoogleFonts.outfit(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              if (booking.urgency == 'high')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Text('🚨 Emergency', style: GoogleFonts.outfit(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              Text(
                booking.estimatedPrice != null ? '₹${booking.estimatedPrice!.toStringAsFixed(0)}' : 'Est. ₹500',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(booking.description, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.location_on, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Expanded(child: Text(booking.location, style: GoogleFonts.outfit(fontSize: 13))),
          ]),
          if (booking.scheduledDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(children: [
                const Icon(Icons.event, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text('${booking.scheduledDate!.day}/${booking.scheduledDate!.month}/${booking.scheduledDate!.year} at ${booking.scheduledTime ?? "TBD"}',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.blue)),
              ]),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              // ✅ FIXED: Ignore button now works
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<BookingService>().ignoreBooking(booking.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Job ignored', style: GoogleFonts.outfit(color: Colors.white)),
                        backgroundColor: Colors.grey[700],
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Ignore', style: GoogleFonts.outfit(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              // ✅ FIXED: Accept with ETA dialog
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _showAcceptDialog(context, booking, providerId, providerName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Accept Job', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1);
  }

  // ── Accept Dialog with ETA ─────────────────────────────────────
  void _showAcceptDialog(BuildContext context, Booking booking,
      String providerId, String providerName) {
    String selectedEta = '30 mins';
    final etaOptions = ['15 mins', '30 mins', '45 mins', '1 hour', '2 hours'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Accept Job', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${booking.serviceType}', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            Text('Location: ${booking.location}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            Text('Your ETA:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StatefulBuilder(builder: (_, setInner) => Wrap(
              spacing: 8,
              children: etaOptions.map((eta) => ChoiceChip(
                label: Text(eta, style: GoogleFonts.outfit(fontSize: 12)),
                selected: selectedEta == eta,
                onSelected: (_) => setInner(() => selectedEta = eta),
                selectedColor: const Color(0xFF1A237E),
                labelStyle: TextStyle(color: selectedEta == eta ? Colors.white : null),
              )).toList(),
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<BookingService>().acceptBooking(
                bookingId: booking.id,
                providerId: providerId,
                providerName: providerName,
                eta: selectedEta,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('✅ Job Accepted! ETA: $selectedEta',
                  style: GoogleFonts.outfit(color: Colors.white)),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ));
              _tabController.animateTo(1);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
            child: Text('Confirm', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── My Jobs Card (Active/Completed) ───────────────────────────────
  Widget _buildMyJobCard(BuildContext context, Booking booking, int index) {
    final statusColor = booking.status == BookingStatus.accepted ? Colors.blue
        : booking.status == BookingStatus.inProgress ? Colors.orange
        : booking.status == BookingStatus.completed ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(booking.serviceType, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(booking.status.label, style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(booking.location, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
          Text(booking.description, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          // Action buttons based on status
          if (booking.status == BookingStatus.accepted)
            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_run, size: 16),
                label: Text('I\'ve Arrived — Start Job', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onPressed: () => context.read<BookingService>().markInProgress(booking.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ))
          else if (booking.status == BookingStatus.inProgress)
            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, size: 16),
                label: Text('Mark as Completed', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onPressed: () => _showCompleteDialog(context, booking.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms);
  }

  void _showCompleteDialog(BuildContext context, String bookingId) {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Complete Job', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Enter the final charge for this job:', style: GoogleFonts.outfit(color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: 'e.g. 1200',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceController.text);
              Navigator.pop(ctx);
              await context.read<BookingService>().completeBooking(bookingId, finalPrice: price ?? 0);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('✅ Job marked as completed!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Confirm', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.coffee, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('Take a break!', style: GoogleFonts.outfit(fontSize: 20, color: Colors.grey)),
      Text('Toggle online to receive jobs', style: GoogleFonts.outfit(color: Colors.grey[400])),
    ]),
  );

  Widget _buildEmptyState(String message, IconData icon) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text(message, style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
    ]),
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

// lib/features/profile/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../../../../utils/app_colors.dart';

class ProfileHeader extends ConsumerWidget {
  final int orderCount;
  final String fallbackName;

  const ProfileHeader({
    super.key,
    required this.orderCount,
    required this.fallbackName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    
    // We assume data is available because ProfileTab handles loading/error
    final user = profileAsync.value;
    final isGuest = user == null;
    final name = user?.name ?? fallbackName;
    final initials = user?.initials ?? (name.isNotEmpty ? name[0].toUpperCase() : '👤');

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isGuest
                ? const [Color(0xFF757575), Color(0xFF424242)]
                : const [AppColors.primaryBlue, Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isGuest ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isGuest ? Colors.orange : Colors.green,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGuest ? Icons.public : Icons.verified_user,
                    color: isGuest ? Colors.orange : Colors.green,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isGuest ? '👤 GUEST USER' : '✓ VERIFIED USER',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isGuest ? Colors.orange : Colors.green,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 300.ms),
            const SizedBox(height: 18),
            
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isGuest
                    ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[600]!])
                    : const LinearGradient(colors: [Color(0xFF5E35B1), Color(0xFF1A237E)]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().scale(duration: 400.ms, delay: 50.ms),
            const SizedBox(height: 16),
            
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats row
            if (!isGuest)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip("$orderCount", "Orders"),
                  const SizedBox(width: 16),
                  _statChip("${user.totalJobs}", "Jobs"),
                  const SizedBox(width: 16),
                  _statChip("⭐ ${user.rating.toStringAsFixed(1)}", "Rating"),
                ],
              )
            else
              Text(
                "Sign in to access your profile",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _statChip(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

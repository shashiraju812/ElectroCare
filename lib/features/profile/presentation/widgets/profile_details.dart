// lib/features/profile/presentation/widgets/profile_details.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../screens/auth/role_selection_screen.dart';
import 'edit_profile_dialog.dart';

class ProfileDetails extends ConsumerWidget {
  final AuthService auth;

  const ProfileDetails({
    super.key,
    required this.auth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return profileAsync.maybeWhen(
      data: (user) {
        final isGuest = user == null;
        final name = user?.name ?? 'Guest User';
        final phone = user?.phone ?? '';
        final email = user?.email ?? '';

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isGuest) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("👤 Account Information"),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                        onPressed: () => showEditProfileDialog(context, auth, user, ref),
                        tooltip: 'Edit Profile',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _infoCard([
                    _infoRow(Icons.person, "Full Name", name),
                    const Divider(height: 1),
                    _infoRow(Icons.phone, "Phone Number", phone.isNotEmpty ? phone : '— Not provided'),
                    const Divider(height: 1),
                    _infoRow(Icons.home, "Address", user.address ?? '— Not provided'),
                    const Divider(height: 1),
                    _infoRow(Icons.email_outlined, "Email Address (Read-only)", email.isNotEmpty ? email : '— Not provided'),
                  ]),
                ] else ...[
                  _sectionTitle("👤 Guest Profile"),
                  const SizedBox(height: 10),
                  _buildGuestView(context),
                ],
              ],
            ),
          ),
        );
      },
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.public, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            "You are browsing as Guest",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sign in with your phone, email, or Google account to access your profile, orders, and bookings.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign In / Register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }
}

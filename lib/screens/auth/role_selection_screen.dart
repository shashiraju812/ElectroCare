import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../models/user_role.dart';
import '../user/user_home_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../provider/provider_dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Who are you?',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 10),
              Text(
                'Select your role to continue',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 40),

              Expanded(
                child: ListView(
                  children: [
                    _buildRoleCard(
                      context,
                      title: 'Customer',
                      subtitle: 'Browse products & book appointments',
                      icon: Icons.person_outline_rounded,
                      color: AppColors.primaryBlue,
                      role: UserRole.user,
                      delay: 0,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      context,
                      title: 'Shop Owner',
                      subtitle: 'Manage inventory & orders',
                      icon: Icons.store_mall_directory_rounded,
                      color: AppColors.accentAmber,
                      role: UserRole.owner,
                      delay: 100,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      context,
                      title: 'Service Provider',
                      subtitle: 'Receive jobs & track requests',
                      icon: Icons.engineering_rounded,
                      color: const Color(
                        0xFF43A047,
                      ), // Keep Green for distinctiveness or move to Blue/Amber mix
                      role: UserRole.provider,
                      delay: 200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required UserRole role,
    required int delay,
  }) {
    return InkWell(
      onTap: () {
        final authService = Provider.of<AuthService>(context, listen: false);
        authService.setRole(role);

        Widget nextScreen;
        switch (role) {
          case UserRole.user:
            nextScreen = const UserHomeScreen();
            break;
          case UserRole.owner:
            nextScreen = const OwnerDashboardScreen();
            break;
          case UserRole.provider:
            nextScreen = const ProviderDashboardScreen();
            break;
        }

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => nextScreen),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2);
  }
}

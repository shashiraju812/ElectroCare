// lib/features/profile/presentation/widgets/profile_settings.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/language_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../screens/auth/role_selection_screen.dart';

class ProfileSettings extends StatelessWidget {
  final bool isGuest;
  final AuthService auth;
  final LanguageService langService;

  const ProfileSettings({
    super.key,
    required this.isGuest,
    required this.auth,
    required this.langService,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("⚙️ Settings & Preferences"),
            const SizedBox(height: 10),
            _infoCard([
              _settingRow(
                Icons.language,
                "App Language",
                "${langService.currentLanguage.flag} ${langService.currentLanguage.name}",
                onTap: () => _showProfessionalLanguageDialog(context),
              ),
              const Divider(height: 1),
              _settingRow(
                Icons.notifications_outlined,
                "Notifications",
                "Enabled",
              ),
              const Divider(height: 1),
              _settingRow(
                Icons.security,
                "Security",
                "Password protected",
              ),
              const Divider(height: 1),
              _settingRow(
                Icons.info_outline,
                "App Version",
                "v2.0.0",
              ),
            ]),
            const SizedBox(height: 16),

            // Action Buttons Row
            Row(
              children: [
                if (!isGuest)
                  Expanded(
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
                        "Sign Out",
                        style: GoogleFonts.outfit(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),
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

  void _showProfessionalLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select Language",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose your preferred language for the app",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: LanguageService.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final lang = LanguageService.supportedLanguages[index];
                  final isSelected = lang.code == langService.currentCode;
                  
                  return GestureDetector(
                    onTap: () {
                      langService.setLanguage(lang.code);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  Color(0xFF3949AB),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          Text(
                            lang.name,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            lang.nativeName,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 6),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Your language preference will be saved and applied immediately.",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
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
}

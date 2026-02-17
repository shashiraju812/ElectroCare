import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import 'role_selection_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isEmailLogin = true;
  bool _usePassword = true;
  bool _otpSent = false;
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordOtpController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _contactController.dispose();
    _passwordOtpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final contact = _contactController.text;

    if (_usePassword) {
      final success = await authService.loginWithPassword(
        contact,
        _passwordOtpController.text,
      );
      if (mounted) {
        _handleAuthResult(success, "Invalid Password. Try 'password123'");
      }
    } else {
      if (!_otpSent) {
        await authService.sendOtp(contact);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _passwordOtpController.clear();
          });
        }
      } else {
        final success = await authService.verifyOtp(
          contact,
          _passwordOtpController.text,
        );
        if (mounted) {
          _handleAuthResult(success, "Invalid OTP. Try 1234");
        }
      }
    }
  }

  void _handleAuthResult(bool success, String errorMsg) {
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWhite,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Green Logo
              Text(
                'ElectroCare',
                style: GoogleFonts.grandHotel(
                  fontSize: 56,
                  color: AppColors.primaryGreen,
                  letterSpacing: 1.0,
                ),
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 10),
              Text(
                'Electrical Solutions',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppColors.textGrey,
                  letterSpacing: 1.0,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 40),

              // Simple Clean Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    if (!_otpSent)
                      Row(
                        children: [
                          Expanded(
                            child: _buildToggleButton(
                              "Email",
                              _isEmailLogin,
                              () => setState(() => _isEmailLogin = true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildToggleButton(
                              "Phone",
                              !_isEmailLogin,
                              () => setState(() => _isEmailLogin = false),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Contact Input
                    TextField(
                      controller: _contactController,
                      style: const TextStyle(color: AppColors.textBlack),
                      enabled: !_otpSent,
                      decoration: InputDecoration(
                        labelText: _isEmailLogin ? "Email" : "Phone",
                        prefixIcon: Icon(
                          _isEmailLogin
                              ? Icons.email_outlined
                              : Icons.phone_android,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Password/OTP Input
                    if (_usePassword || _otpSent) ...[
                      TextField(
                        controller: _passwordOtpController,
                        obscureText: _usePassword && _obscurePassword,
                        style: const TextStyle(color: AppColors.textBlack),
                        decoration: InputDecoration(
                          labelText: _usePassword ? "Password" : "OTP Code",
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primaryGreen,
                          ),
                          suffixIcon: _usePassword
                              ? IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.iconGrey,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if (!_otpSent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _usePassword = !_usePassword),
                            child: Text(
                              _usePassword
                                  ? "Use OTP instead"
                                  : "Use Password instead",
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Login Button (Green)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _otpSent
                                    ? "Verify & Login"
                                    : (_usePassword ? "Login" : "Send OTP"),
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    if (_otpSent)
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() {
                            _otpSent = false;
                            _passwordOtpController.clear();
                          }),
                          child: const Text(
                            "Change Number/Email",
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 30),

              // Create Account Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                "Or continue with",
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(FontAwesomeIcons.google, () async {
                    final authService = Provider.of<AuthService>(
                      context,
                      listen: false,
                    );
                    await authService.loginWithGoogle();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen(),
                        ),
                      );
                    }
                  }),
                  const SizedBox(width: 20),
                  _buildSocialIcon(FontAwesomeIcons.instagram, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.igGrey,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: isSelected ? AppColors.primaryGreen : AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.igGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: FaIcon(icon, color: AppColors.textBlack, size: 20),
      ),
    );
  }
}

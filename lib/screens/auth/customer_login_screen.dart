import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import '../../models/user_role.dart';
import '../user/user_home_screen.dart';
import 'signup_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  bool _isEmailLogin = true;
  bool _usePassword = true;
  bool _otpSent = false;
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordOtpController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color _themeColor = AppColors.primaryBlue;
  static const Color _themeColorLight = Color(0xFF3949AB);

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
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.setRole(UserRole.user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Role Icon
              Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_themeColor, _themeColorLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _themeColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 24),
              Text(
                'Welcome, Customer!',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _themeColor,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Browse products & book appointments',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 36),

              // Login Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
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
                      style: const TextStyle(color: AppColors.textDark),
                      enabled: !_otpSent,
                      decoration: InputDecoration(
                        labelText: _isEmailLogin ? "Email" : "Phone",
                        prefixIcon: Icon(
                          _isEmailLogin
                              ? Icons.email_outlined
                              : Icons.phone_android,
                          color: _themeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Password/OTP
                    if (_usePassword || _otpSent) ...[
                      TextField(
                        controller: _passwordOtpController,
                        obscureText: _usePassword && _obscurePassword,
                        style: const TextStyle(color: AppColors.textDark),
                        decoration: InputDecoration(
                          labelText: _usePassword ? "Password" : "OTP Code",
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: _themeColor,
                          ),
                          suffixIcon: _usePassword
                              ? IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.textGrey,
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
                              style: const TextStyle(color: _themeColor),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: _themeColor.withValues(alpha: 0.4),
                        ),
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
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Create Account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: _themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                "Or continue with",
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              _buildSocialIcon(FontAwesomeIcons.google, () async {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                await authService.loginWithGoogle();
                authService.setRole(UserRole.user);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const UserHomeScreen()),
                  );
                }
              }),
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
              ? _themeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _themeColor : AppColors.igGrey,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: isSelected ? _themeColor : AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.igGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FaIcon(icon, color: AppColors.textDark, size: 22),
      ),
    );
  }
}

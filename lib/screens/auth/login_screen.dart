// lib/screens/auth/login_screen.dart
// General login screen — used by customers. Fixed for new AuthService API.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import '../../models/user_role.dart';
import 'role_selection_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _otpSent = false;
  String? _verificationId;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.length != 10) {
      _showSnack('Enter a valid 10-digit phone number');
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthService>();
    await auth.sendOtp(
      phone: _phoneController.text,
      role: UserRole.user,
      onCodeSent: (vid) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _otpSent = true;
          _verificationId = vid;
        });
        _showSnack('OTP sent! (Use any 6-digit code in demo mode)');
      },
      onError: (err) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnack('Error: $err');
        }
      },
    );
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 6) {
      _showSnack('Enter the 6-digit OTP');
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthService>();
    final success = await auth.verifyOtp(
      verificationId: _verificationId ?? '',
      otp: _otpController.text,
      phone: _phoneController.text,
      role: UserRole.user,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
    } else {
      _showSnack('Invalid OTP. In demo mode, any 6 digits work.');
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    await context.read<AuthService>().loginAsGuest(role: UserRole.user);
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    await context.read<AuthService>().loginWithGoogle(role: UserRole.user);
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
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
              // Logo
              Text('ElectroCare',
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                )).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 6),
              Text('Electrical Products & Services',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppColors.textGrey,
                )).animate().fadeIn(delay: 200.ms),

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
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign In',
                      style: GoogleFonts.outfit(
                        fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text('Welcome back to ElectroCare',
                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
                    const SizedBox(height: 20),

                    // Phone field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !_otpSent,
                      style: const TextStyle(color: AppColors.textBlack),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixText: '+91 ',
                        prefixIcon: Icon(Icons.phone_android, color: AppColors.primaryBlue),
                        hintText: '10-digit mobile number',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // OTP field (shown after sending)
                    if (_otpSent) ...[
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(color: AppColors.textBlack, letterSpacing: 8),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Enter 6-digit OTP',
                          counterText: '',
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() { _otpSent = false; _otpController.clear(); }),
                          child: const Text('Change Number', style: TextStyle(color: AppColors.textGrey)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Primary action button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_otpSent ? _handleVerifyOtp : _handleSendOtp),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _otpSent ? 'Verify OTP & Login' : 'Send OTP',
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Guest button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.person_outline),
                        label: Text('Continue as Guest',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                        onPressed: _isLoading ? null : _handleGuestLogin,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Social login
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or sign in with', style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 13)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                icon: FontAwesomeIcons.google,
                label: 'Sign in with Google',
                onTap: _handleGoogleLogin,
                color: const Color(0xFFEA4335),
              ),

              const SizedBox(height: 24),

              // Signup link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                    style: GoogleFonts.outfit(color: AppColors.textGrey)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: Text('Create Account',
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

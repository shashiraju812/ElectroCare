// lib/screens/auth/customer_login_screen.dart
// ─────────────────────────────────────────────────────────────────
// UPGRADED: Wired to real Firebase Auth (Phone OTP + Google)
// Dev mode shows hint credentials. Production mode uses real OTP.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_config.dart';
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
  bool _usePhone = true;
  bool _otpSent = false;
  String? _verificationId;

  final _phoneController   = TextEditingController();
  final _emailController   = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  static const Color _themeColor = AppColors.primaryBlue;
  static const Color _themeColorLight = Color(0xFF3949AB);

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Send OTP ──────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _setError('Please enter a valid 10-digit phone number');
      return;
    }
    _setLoading(true);
    final auth = context.read<AuthService>();

    if (AppConfig.useMockData) {
      // Dev mode: skip real OTP
      await Future.delayed(const Duration(seconds: 1));
      setState(() { _otpSent = true; _isLoading = false; });
      _showInfo('Dev mode: use any 6-digit code (e.g. 123456)');
      return;
    }

    await auth.sendOtp(
      phone: phone,
      role: UserRole.user,
      onCodeSent: (verificationId) {
        setState(() { _verificationId = verificationId; _otpSent = true; _isLoading = false; });
      },
      onError: (error) => setState(() { _errorMessage = error; _isLoading = false; }),
    );
  }

  // ── Verify OTP ────────────────────────────────────────────────────
  Future<void> _verifyOtp(String otp) async {
    _setLoading(true);
    final auth = context.read<AuthService>();

    bool success;
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      success = otp.length == 6; // Any 6-digit OTP in dev
    } else {
      success = await auth.verifyOtp(
        verificationId: _verificationId ?? '',
        otp: otp,
        phone: _phoneController.text.trim(),
        role: UserRole.user,
      );
    }

    if (!mounted) return;
    _setLoading(false);
    if (success) {
      _navigateToHome();
    } else {
      _setError('Invalid OTP. Please try again.');
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────
  Future<void> _googleLogin() async {
    _setLoading(true);
    final auth = context.read<AuthService>();
    final success = await auth.loginWithGoogle(role: UserRole.user);
    if (!mounted) return;
    _setLoading(false);
    if (success) {
      _navigateToHome();
    } else {
      _setError('Google sign-in failed. Please try again.');
    }
  }

  // ── Guest / Password Login (dev mode convenience) ─────────────────
  Future<void> _guestLogin() async {
    _setLoading(true);
    final auth = context.read<AuthService>();
    await auth.loginAsGuest(role: UserRole.user);
    if (!mounted) return;
    _setLoading(false);
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomeScreen()));
  }

  void _setLoading(bool v) => setState(() { _isLoading = v; _errorMessage = null; });
  void _setError(String msg) => setState(() { _errorMessage = msg; _isLoading = false; });
  void _showInfo(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: GoogleFonts.outfit()), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => _otpSent ? setState(() => _otpSent = false) : Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_themeColor, _themeColorLight]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: _themeColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 48),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 20),
            Text('Welcome, Customer!', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: _themeColor)).animate().fadeIn(delay: 200.ms),
            Text('Browse products & book services', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),

            // Main Login Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_otpSent) ...[
                    // Phone / Email Toggle
                    Row(children: [
                      Expanded(child: _buildToggle('Phone', _usePhone, () => setState(() => _usePhone = true))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildToggle('Email', !_usePhone, () => setState(() => _usePhone = false))),
                    ]),
                    const SizedBox(height: 18),

                    if (_usePhone) ...[
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: GoogleFonts.outfit(),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixText: '+91 ',
                          counterText: '',
                          prefixIcon: const Icon(Icons.phone_android, color: _themeColor),
                          helperText: AppConfig.useMockData ? 'Dev: Enter any 10 digits' : null,
                          helperStyle: const TextStyle(color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(backgroundColor: _themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : Text('Send OTP', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ] else ...[
                      TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                      const SizedBox(height: 12),
                      TextFormField(controller: _passwordController, obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        )),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _guestLogin,
                          style: ElevatedButton.styleFrom(backgroundColor: _themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : Text('Login', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ] else ...[
                    // OTP Entry
                    Text('Enter OTP', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Sent to +91 ${_phoneController.text}', style: GoogleFonts.outfit(color: Colors.grey)),
                    const SizedBox(height: 24),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 50, fieldWidth: 44,
                        activeFillColor: Colors.white,
                        selectedFillColor: const Color(0xFFEEF2FF),
                        inactiveFillColor: Colors.grey[100]!,
                        activeColor: _themeColor,
                        selectedColor: _themeColor,
                        inactiveColor: Colors.grey[300]!,
                      ),
                      enableActiveFill: true,
                      onCompleted: _verifyOtp,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _sendOtp,
                        child: Text('Resend OTP', style: GoogleFonts.outfit(color: _themeColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (_isLoading) const LinearProgressIndicator(),
                  ],

                  // Error
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage!, style: GoogleFonts.outfit(color: Colors.red, fontSize: 13))),
                      ]),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Guest Mode
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _guestLogin,
                icon: const Icon(Icons.person_outline, size: 20),
                label: Text('Continue as Guest', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _themeColor, side: const BorderSide(color: _themeColor, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Row(children: [
              Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(color: AppColors.textGrey))), Expanded(child: Divider()),
            ]),
            const SizedBox(height: 16),

            // Google Sign-In
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _googleLogin,
                icon: const FaIcon(FontAwesomeIcons.google, size: 18),
                label: Text('Sign in with Google', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87, side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Don't have an account? ", style: GoogleFonts.outfit(color: AppColors.textGrey)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: Text('Create Account', style: GoogleFonts.outfit(color: _themeColor, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _themeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? _themeColor : Colors.grey[300]!),
        ),
        child: Center(child: Text(text, style: GoogleFonts.outfit(
          color: isSelected ? _themeColor : AppColors.textGrey, fontWeight: FontWeight.w600))),
      ),
    );
  }
}

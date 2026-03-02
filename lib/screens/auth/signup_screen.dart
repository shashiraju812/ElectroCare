import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import '../../models/user_role.dart';
import '../user/user_home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const _green = AppColors.primaryGreen;
  static const _blue = AppColors.primaryBlue;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    // Pass phone as primary contact for the account
    final contact = _phoneController.text.isNotEmpty
        ? _phoneController.text
        : _emailController.text;

    final success = await authService.registerUser(
      _nameController.text,
      contact,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Auto login after signup → go to home
      authService.setRole(UserRole.user);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8F5E9),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Account Created! 🎉",
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                // Trilingual welcome
                Text(
                  "ఖాతా తయారైంది! | खाता बन गया!",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserHomeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text("Go to Home"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Failed. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_green, Color(0xFF00897B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: _green.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ).animate().scale(duration: 400.ms),
                      const SizedBox(height: 18),
                      Text(
                        'Create Account',
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Trilingual subtitle
                      Text(
                        'Join ElectroCare • ఎలెక్ట్రోకేర్ లో చేరండి • जुड़ें',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // ─── FORM CARD ───────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("👤 Personal Info"),
                      const SizedBox(height: 12),

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(color: AppColors.textBlack),
                        decoration: _inputDec(
                          label: "Full Name",
                          hint: "e.g. Raju Kumar",
                          icon: Icons.person_outline,
                          color: _green,
                        ),
                        validator: (v) =>
                            v!.trim().isEmpty ? "Enter your name" : null,
                      ),

                      const SizedBox(height: 16),
                      _sectionLabel("📞 Contact Details"),
                      const SizedBox(height: 4),
                      Text(
                        "మీ నంబర్ మరియు ఇమెయిల్ ఇవ్వండి  •  अपना नंबर और ईमेल दें",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: const TextStyle(color: AppColors.textBlack),
                        decoration: _inputDec(
                          label: "Phone Number  •  ఫోన్ నంబర్",
                          hint: "10-digit mobile number",
                          icon: Icons.phone_android,
                          color: _blue,
                          prefix: "+91 ",
                        ),
                        validator: (v) {
                          if (v!.isEmpty && _emailController.text.isEmpty) {
                            return "Enter phone or email (at least one)";
                          }
                          if (v.isNotEmpty && v.length != 10) {
                            return "Enter a valid 10-digit number";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.textBlack),
                        decoration: _inputDec(
                          label: "Email Address  •  ఇమెయిల్",
                          hint: "example@gmail.com",
                          icon: Icons.email_outlined,
                          color: _blue,
                        ),
                        validator: (v) {
                          if (v!.isEmpty && _phoneController.text.isEmpty) {
                            return "Enter phone or email (at least one)";
                          }
                          if (v.isNotEmpty &&
                              !RegExp(r'^[\w-.]+@[\w-]+\.\w+$').hasMatch(v)) {
                            return "Enter a valid email address";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                      _sectionLabel("🔒 Security"),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.textBlack),
                        decoration: _inputDec(
                          label: "Password  •  పాస్‌వర్డ్",
                          hint: "Min. 6 characters",
                          icon: Icons.lock_outline,
                          color: _green,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.textGrey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            v!.length < 6 ? "Minimum 6 characters" : null,
                      ),

                      const SizedBox(height: 14),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(color: AppColors.textBlack),
                        decoration: _inputDec(
                          label: "Confirm Password  •  నిర్ధారించండి",
                          hint: "Re-enter password",
                          icon: Icons.lock_outline,
                          color: _green,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.textGrey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleRegister,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.person_add, size: 22),
                    label: Text(
                      _isLoading
                          ? "Creating Account..."
                          : "Sign Up  •  నమోదు చేయండి",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: _green.withValues(alpha: 0.4),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already registered? ",
                        style: GoogleFonts.outfit(color: AppColors.textGrey),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Login",
                          style: GoogleFonts.outfit(
                            color: _blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textBlack,
      ),
    );
  }

  InputDecoration _inputDec({
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    String? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: color, size: 20),
      prefixText: prefix,
      prefixStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      labelStyle: TextStyle(color: color, fontSize: 13),
    );
  }
}

// lib/main.dart — ElectroCare App Entry Point (Firebase Enabled)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'utils/app_colors.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/payment_service.dart';
import 'services/ai_service.dart';
import 'services/language_service.dart';
import 'screens/auth/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Firebase ───────────────────────────────────
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AiService.initialize();

  // Initialize language service
  final languageService = LanguageService();
  await languageService.initialize();

  runApp(ElectroCareApp(languageService: languageService));
}

class ElectroCareApp extends StatelessWidget {
  final LanguageService languageService;

  const ElectroCareApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BookingService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) {
          final os = OrderService();
          os.listenToAllOrders();
          return os;
        }),
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider(create: (_) {
          final ps = PaymentService();
          ps.initialize();
          return ps;
        }),
      ],
      child: Consumer<LanguageService>(
        builder: (context, langService, _) {
          return MaterialApp(
            title: 'ElectroCare',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            locale: langService.currentLocale,
            supportedLocales: LanguageService.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const RoleSelectionScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentAmber,
        surface: AppColors.cardWhite,
        error: AppColors.errorRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.cardWhite,
        foregroundColor: AppColors.textDark,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorRed)),
        hintStyle: const TextStyle(color: AppColors.textGrey),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

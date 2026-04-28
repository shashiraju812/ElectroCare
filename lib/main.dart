// lib/main.dart — ElectroCare App Entry Point

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/payment_service.dart';
import 'services/language_service.dart';
import 'services/firestore_init_service.dart';
import 'services/maps_service.dart';
import 'screens/auth/role_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase init ──
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      debugPrint('⚠️ Firebase init error: $e');
    }
  }

  // ── Firestore collections (non-fatal) ──
  try {
    await FirestoreInitService.initializeCollections();
  } catch (e) {
    debugPrint('⚠️ Firestore init (non-fatal): $e');
  }

  // ── Language init (non-fatal) ──
  final languageService = LanguageService();
  try {
    await languageService.initialize();
  } catch (e) {
    debugPrint('⚠️ Language service init (non-fatal): $e');
  }
  
  // ── Local Storage ──
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: EELECTROCAREApp(languageService: languageService),
    ),
  );
}

// Global provider for shared preferences (DI)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Initialized in main
});

class EELECTROCAREApp extends StatelessWidget {
  final LanguageService languageService;

  const EELECTROCAREApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return legacy.MultiProvider(
      providers: [
        legacy.ChangeNotifierProvider(create: (_) => AuthService()),
        legacy.ChangeNotifierProvider(create: (_) => BookingService()),
        legacy.ChangeNotifierProvider(create: (_) => ProductService()),
        legacy.ChangeNotifierProvider(create: (_) => CartService()),
        legacy.ChangeNotifierProvider(create: (_) => OrderService()),
        legacy.ChangeNotifierProvider.value(value: languageService),
        legacy.ChangeNotifierProvider(create: (_) => MapsService()),
        legacy.ChangeNotifierProvider(create: (_) => PaymentService()),
      ],
      child: legacy.Consumer<LanguageService>(
        builder: (context, langService, _) {
          return MaterialApp(
            title: 'Electrocare',
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
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      textTheme: GoogleFonts.outfitTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

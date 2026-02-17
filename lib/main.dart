import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: MaterialApp(
        title: 'ElectroCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.igBlack,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.candyAppleRed,
            secondary: AppColors.candyAppleRed,
            surface: AppColors.igBlack,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.igBlack,
            foregroundColor: AppColors.igWhite,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.candyAppleRed),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.igGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            hintStyle: const TextStyle(color: AppColors.igSecondaryText),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

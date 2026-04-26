// lib/services/language_service.dart
// ─────────────────────────────────────────────────────────────────
// Lightweight language/locale service for Indian language support.
// Persists selection to SharedPreferences.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}

class LanguageService extends ChangeNotifier {
  static const String _prefKey = 'app_language';

  Locale _currentLocale = const Locale('en');
  String _currentCode = 'en';

  // ── Supported Languages ────────────────────────────────────────
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      locale: Locale('en'),
    ),
    AppLanguage(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
      locale: Locale('te'),
    ),
    AppLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिंदी',
      flag: '🇮🇳',
      locale: Locale('hi'),
    ),
    AppLanguage(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
      locale: Locale('ta'),
    ),
    AppLanguage(
      code: 'kn',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      flag: '🇮🇳',
      locale: Locale('kn'),
    ),
    AppLanguage(
      code: 'ml',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      flag: '🇮🇳',
      locale: Locale('ml'),
    ),
    AppLanguage(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇮🇳',
      locale: Locale('bn'),
    ),
  ];

  static List<Locale> get supportedLocales =>
      supportedLanguages.map((l) => l.locale).toList();

  // ── Getters ────────────────────────────────────────────────────
  Locale get currentLocale => _currentLocale;
  String get currentCode => _currentCode;

  AppLanguage get currentLanguage => supportedLanguages.firstWhere(
        (l) => l.code == _currentCode,
        orElse: () => supportedLanguages.first,
      );

  // ── Initialize from SharedPreferences ─────────────────────────
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey) ?? 'en';
    _currentCode = savedCode;
    _currentLocale = Locale(savedCode);
    notifyListeners();
  }

  // ── Set Language ──────────────────────────────────────────────
  Future<void> setLanguage(String code) async {
    if (_currentCode == code) return;
    _currentCode = code;
    _currentLocale = Locale(code);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }
}

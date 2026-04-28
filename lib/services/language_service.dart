// services/language_service.dart
// ─────────────────────────────────────────────────────────────────
// Language/locale service for multilingual app support.
// Persists selection to SharedPreferences with app-wide translations.
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
  Map<String, Map<String, String>> _translations = {};

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
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिंदी',
      flag: '🇮🇳',
      locale: Locale('hi'),
    ),
    AppLanguage(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
      locale: Locale('te'),
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

  // ── Initialize translations ────────────────────────────────────
  void _initializeTranslations() {
    _translations = {
      'en': {
        'app_title': 'ElectroCare',
        'home': 'Home',
        'products': 'Products',
        'services': 'Services',
        'orders': 'Orders',
        'profile': 'Profile',
        'cart': 'Cart',
        'search': 'Search',
        'settings': 'Settings',
        'logout': 'Logout',
        'login': 'Login',
        'signup': 'Sign Up',
        'email': 'Email',
        'password': 'Password',
        'phone': 'Phone',
        'address': 'Address',
        'save': 'Save',
        'cancel': 'Cancel',
        'delete': 'Delete',
        'edit': 'Edit',
        'loading': 'Loading...',
        'error': 'Error',
        'success': 'Success',
        'welcome': 'Welcome to ElectroCare',
        'electrical_products': 'Electrical Products',
        'electrical_services_category': 'Electrical Services',
        'best_sellers': 'Best Sellers',
        'new_arrivals': 'New Arrivals',
        'add_to_cart': 'Add to Cart',
        'price': 'Price',
        'quantity': 'Quantity',
        'total': 'Total',
        'checkout': 'Checkout',
        'delivery_address': 'Delivery Address',
        'payment_method': 'Payment Method',
        'order_status': 'Order Status',
        'track_order': 'Track Order',
        'rating': 'Rating',
        'reviews': 'Reviews',
        'write_review': 'Write Review',
      },
      'hi': {
        'app_title': 'इलेक्ट्रोकेयर',
        'home': 'होम',
        'products': 'उत्पाद',
        'services': 'सेवाएं',
        'orders': 'ऑर्डर',
        'profile': 'प्रोफाइल',
        'cart': 'कार्ट',
        'search': 'खोज',
        'settings': 'सेटिंग्स',
        'logout': 'लॉगआउट',
        'login': 'लॉगिन',
        'signup': 'साइन अप',
        'email': 'ईमेल',
        'password': 'पासवर्ड',
        'phone': 'फोन',
        'address': 'पता',
        'save': 'बचाएं',
        'cancel': 'रद्द करें',
        'delete': 'हटाएं',
        'edit': 'संपादित करें',
        'loading': 'लोड हो रहा है...',
        'error': 'त्रुटि',
        'success': 'सफल',
        'welcome': 'ElectroCare में आपका स्वागत है',
        'electrical_products': 'विद्युत उत्पाद',
        'electrical_services_category': 'विद्युत सेवाएं',
        'best_sellers': 'सर्वश्रेष्ठ विक्रेता',
        'new_arrivals': 'नए आगमन',
        'add_to_cart': 'कार्ट में जोड़ें',
        'price': 'कीमत',
        'quantity': 'मात्रा',
        'total': 'कुल',
        'checkout': 'चेकआउट',
        'delivery_address': 'डिलीवरी पता',
        'payment_method': 'भुगतान विधि',
        'order_status': 'ऑर्डर स्थिति',
        'track_order': 'ऑर्डर ट्रैक करें',
        'rating': 'रेटिंग',
        'reviews': 'समीक्षा',
        'write_review': 'समीक्षा लिखें',
      },
      'te': {
        'app_title': 'ఎలెక్ట్రోకేర్',
        'home': 'ఇల్లు',
        'products': 'ఉత్పత్తులు',
        'services': 'సేవలు',
        'orders': 'ఆర్డర్లు',
        'profile': 'ప్రొఫైల్',
        'cart': 'కార్ట్',
        'search': 'సెర్చ్',
        'settings': 'సెట్టింగ్‌లు',
        'logout': 'లాగ్‌అవుట్',
        'login': 'లాగిన్',
        'signup': 'సైన్ అప్',
        'email': 'ఇమెయిల్',
        'password': 'పాస్‌వర్డ్',
        'phone': 'ఫోన్',
        'address': 'చిరునామా',
        'save': 'సేవ్ చేయి',
        'cancel': 'రద్దు చేయి',
        'delete': 'తొలగించండి',
        'edit': 'సవరించు',
        'loading': 'లోడ్ అవుతోంది...',
        'error': 'ఎర్రర్',
        'success': 'విజయం',
        'welcome': 'ఎలెక్ట్రోకేర్‌కు స్వాగతం',
        'electrical_products': 'విద్యుత్ ఉత్పత్తులు',
        'electrical_services_category': 'విద్యుత్ సేవలు',
        'best_sellers': 'ఉత్తమ విక్రేతలు',
        'new_arrivals': 'కొత్త రాక',
        'add_to_cart': 'కార్టులో జోడించండి',
        'price': 'ధర',
        'quantity': 'పరిమాణం',
        'total': 'మొత్తం',
        'checkout': 'చెక్‌అవుట్',
        'delivery_address': 'డెలివరీ చిరునామా',
        'payment_method': 'చెల్లింపు పద్ధతి',
        'order_status': 'ఆర్డర్ స్థితి',
        'track_order': 'ఆర్డర్‌ను ట్రాక్ చేయండి',
        'rating': 'రేటింగ్',
        'reviews': 'సమీక్షలు',
        'write_review': 'సమీక్ష రాయండి',
      },
    };
  }

  // ── Initialize from SharedPreferences ─────────────────────────
  Future<void> initialize() async {
    _initializeTranslations();
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

  // ── Get translated string ─────────────────────────────────────
  String translate(String key) {
    return _translations[_currentCode]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }

  // ── Get translation for specific language ──────────────────────
  String translateTo(String key, String languageCode) {
    return _translations[languageCode]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }
}

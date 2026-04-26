// lib/services/ai_service.dart
// Mock AI service — keyword-based fallback, no Gemini API key needed

import 'package:flutter/foundation.dart';

class ServiceClassification {
  final String category;
  final String priceRange;
  final String urgency;
  final String summary;
  final List<String> suggestedProducts;

  const ServiceClassification({
    required this.category,
    required this.priceRange,
    required this.urgency,
    required this.summary,
    this.suggestedProducts = const [],
  });

  static ServiceClassification get defaultResult => const ServiceClassification(
        category: 'Inspection',
        priceRange: '500-1000',
        urgency: 'medium',
        summary: 'General electrical inspection required',
      );
}

class AiService {
  static void initialize() {
    // Gemini API initialization goes here
    debugPrint('AiService: running in mock mode');
  }

  static Future<ServiceClassification> classifyBookingRequest(String description) async {
    // Simulate AI delay
    await Future.delayed(const Duration(milliseconds: 600));

    final text = description.toLowerCase();

    // Urgency detection
    String urgency = 'medium';
    if (text.contains('spark') || text.contains('fire') || text.contains('shock') ||
        text.contains('burn') || text.contains('smoke') || text.contains('emergency') ||
        text.contains('danger') || text.contains('urgent')) {
      urgency = 'high';
    } else if (text.contains('check') || text.contains('inspect') ||
        text.contains('test') || text.contains('routine')) {
      urgency = 'low';
    }

    // Category detection
    String category = 'Inspection';
    String priceRange = '500-1000';

    if (text.contains('wire') || text.contains('wiring') || text.contains('cable') ||
        text.contains('short circuit') || text.contains('spark')) {
      category = 'Wiring';
      priceRange = urgency == 'high' ? '1000-3000' : '500-1500';
    } else if (text.contains('fan') || text.contains('ac') || text.contains('geyser') ||
        text.contains('install') || text.contains('fit') || text.contains('fitting')) {
      category = 'Installation';
      priceRange = '600-2000';
    } else if (text.contains('repair') || text.contains('fix') || text.contains('broken') ||
        text.contains('not work') || text.contains('trip') || text.contains('trip')) {
      category = 'Repair';
      priceRange = '400-1200';
    } else if (text.contains('emergency') || text.contains('urgent') ||
        text.contains('immediately') || text.contains('now')) {
      category = 'Emergency';
      priceRange = '1500-5000';
    } else if (text.contains('inspect') || text.contains('check') ||
        text.contains('audit') || text.contains('survey')) {
      category = 'Inspection';
      priceRange = '300-800';
    }

    return ServiceClassification(
      category: category,
      priceRange: priceRange,
      urgency: urgency,
      summary: 'Detected: $category service ($urgency priority)',
      suggestedProducts: _suggestProducts(category),
    );
  }

  static List<String> _suggestProducts(String category) {
    switch (category) {
      case 'Wiring': return ['Finolex FR Cable', 'MCB 32A'];
      case 'Installation': return ['Anchor Switch Plate', 'Philips LED'];
      case 'Repair': return ['RCCB 40A', 'Surge Guard'];
      default: return ['Philips LED Bulb'];
    }
  }

  static Future<String> generateBusinessInsight(Map<String, dynamic> stats) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final bookings = stats['totalBookings'] ?? 0;
    final revenue = stats['totalRevenue'] ?? 0;
    return '📊 Shop Analytics: $bookings bookings processed. Revenue: ₹$revenue. '
        'Tip: Promote LED bulbs and MCBs for 20% sales boost this month.';
  }
}

// lib/services/ai_service.dart
// Mock AI service — keyword-based estimation, time-aware pricing (no API key needed)

import 'package:flutter/foundation.dart';

class ServiceClassification {
  final String category;
  final String priceRange;
  final String urgency;
  final String summary;
  final List<String> suggestedProducts;
  final int estimatedHours; // NEW: estimated service duration

  const ServiceClassification({
    required this.category,
    required this.priceRange,
    required this.urgency,
    required this.summary,
    this.suggestedProducts = const [],
    this.estimatedHours = 1,
  });

  static ServiceClassification get defaultResult => const ServiceClassification(
        category: 'Inspection',
        priceRange: '200-400',
        urgency: 'medium',
        summary: 'General electrical inspection required',
        estimatedHours: 1,
      );
}

class AiService {
  // Base labour rate per hour (₹ per hour)
  static const int _baseRatePerHour = 150;

  static void initialize() {
    debugPrint('AiService: running in mock mode (time-based pricing)');
  }

  static Future<ServiceClassification> classifyBookingRequest(String description) async {
    // Simulate AI thinking delay
    await Future.delayed(const Duration(milliseconds: 700));

    final text = description.toLowerCase();

    // ── 1. Urgency Detection ──────────────────────────────────────
    String urgency = 'medium';
    if (text.contains('spark') || text.contains('fire') || text.contains('shock') ||
        text.contains('burn') || text.contains('smoke') || text.contains('emergency') ||
        text.contains('danger') || text.contains('urgent') || text.contains('short circuit') ||
        text.contains('blast')) {
      urgency = 'high';
    } else if (text.contains('check') || text.contains('inspect') ||
        text.contains('test') || text.contains('routine') || text.contains('survey')) {
      urgency = 'low';
    }

    // ── 2. Category + Time Estimation ────────────────────────────
    String category = 'Inspection';
    int estimatedHours = 1;

    // --- WIRING ---
    if (text.contains('wire') || text.contains('wiring') || text.contains('cable') ||
        text.contains('short circuit') || text.contains('earthing') ||
        text.contains('conduit') || text.contains('spark')) {
      category = 'Wiring';
      // complexity: long wiring jobs take more time
      if (text.contains('house') || text.contains('room') || text.contains('full') ||
          text.contains('entire') || text.contains('new') || text.contains('complete')) {
        estimatedHours = 4;
      } else if (text.contains('partial') || text.contains('single') || text.contains('one')) {
        estimatedHours = 2;
      } else {
        estimatedHours = 3;
      }
    }

    // --- INSTALLATION ---
    else if (text.contains('fan') || text.contains('ac') || text.contains('air condition') ||
        text.contains('geyser') || text.contains('heater') || text.contains('install') ||
        text.contains('fit') || text.contains('fitting') || text.contains('light') ||
        text.contains('bulb') || text.contains('tube') || text.contains('switchboard') ||
        text.contains('socket') || text.contains('plug') || text.contains('cctv') ||
        text.contains('inverter') || text.contains('solar') || text.contains('meter')) {
      category = 'Installation';
      if (text.contains('ac') || text.contains('air condition') || text.contains('solar') ||
          text.contains('inverter') || text.contains('multiple') || text.contains('cctv')) {
        estimatedHours = 3;
      } else if (text.contains('fan') || text.contains('geyser') || text.contains('heater') ||
          text.contains('switchboard') || text.contains('meter')) {
        estimatedHours = 2;
      } else {
        estimatedHours = 1;
      }
    }

    // --- REPAIR ---
    else if (text.contains('repair') || text.contains('fix') || text.contains('broken') ||
        text.contains('not work') || text.contains('not working') || text.contains('dead') ||
        text.contains('trip') || text.contains('tripped') || text.contains('blown') ||
        text.contains('fuse') || text.contains('mcb') || text.contains('fault') ||
        text.contains('fluctuat')) {
      category = 'Repair';
      if (text.contains('board') || text.contains('panel') || text.contains('distribution') ||
          text.contains('multiple') || text.contains('whole')) {
        estimatedHours = 2;
      } else {
        estimatedHours = 1;
      }
    }

    // --- EMERGENCY ---
    else if (text.contains('emergency') || text.contains('urgent') ||
        text.contains('immediately') || text.contains('asap') || text.contains('now') ||
        text.contains('shock') || text.contains('fire') || text.contains('burn')) {
      category = 'Emergency';
      estimatedHours = 1; // Rapid response — base charge
    }

    // --- INSPECTION ---
    else if (text.contains('inspect') || text.contains('check') ||
        text.contains('audit') || text.contains('survey') || text.contains('routine') ||
        text.contains('test') || text.contains('verify') || text.contains('assess')) {
      category = 'Inspection';
      if (text.contains('full') || text.contains('complete') || text.contains('house') ||
          text.contains('building') || text.contains('entire')) {
        estimatedHours = 2;
      } else {
        estimatedHours = 1;
      }
    }

    // ── 3. Time-Based Price Calculation ──────────────────────────
    // Base: ₹200 visit charge + ₹150/hour labour
    const int visitCharge = 200;
    const int materialBuffer = 100; // Parts & consumables buffer

    int baseMin = visitCharge + (_baseRatePerHour * estimatedHours);
    int baseMax = baseMin + materialBuffer + (_baseRatePerHour * estimatedHours ~/ 2);

    // Urgency multiplier
    if (urgency == 'high') {
      baseMin = (baseMin * 1.5).round();
      baseMax = (baseMax * 1.8).round();
    } else if (urgency == 'low') {
      // No extra charge for routine / low-urgency
    }

    // Category-specific adjustments
    switch (category) {
      case 'Emergency':
        baseMin = (baseMin * 1.5).round();
        baseMax = (baseMax * 2.0).round();
        break;
      case 'Wiring':
        baseMax = (baseMax * 1.3).round(); // Higher parts cost
        break;
      case 'Installation':
        baseMax = (baseMax * 1.2).round();
        break;
      default:
        break;
    }

    // Round to nearest 50 for clean display
    baseMin = (baseMin / 50).round() * 50;
    baseMax = (baseMax / 50).round() * 50;
    if (baseMax <= baseMin) baseMax = baseMin + 200;

    final priceRange = '$baseMin-$baseMax';

    final durationLabel = estimatedHours == 1 ? '~1 hr' : '~$estimatedHours hrs';

    return ServiceClassification(
      category: category,
      priceRange: priceRange,
      urgency: urgency,
      summary: '$category service • $durationLabel • $urgency priority',
      suggestedProducts: _suggestProducts(category),
      estimatedHours: estimatedHours,
    );
  }

  static List<String> _suggestProducts(String category) {
    switch (category) {
      case 'Wiring':    return ['Finolex FR Cable', 'MCB 32A', 'Conduit Pipe'];
      case 'Installation': return ['Anchor Switch Plate', 'Philips LED', 'Capacitor'];
      case 'Repair':    return ['RCCB 40A', 'Surge Guard', 'Fuse Set'];
      case 'Emergency': return ['MCB 32A', 'RCCB 40A', 'Earthing Rod'];
      default:          return ['Philips LED Bulb', 'Tester Pen'];
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

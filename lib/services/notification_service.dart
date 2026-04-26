// lib/services/notification_service.dart
// Stub notification service — no Firebase dependencies

import 'package:flutter/foundation.dart';

class NotificationService {
  static Future<void> initialize() async {
    debugPrint('NotificationService: stub mode');
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('🔔 Notification: $title — $body');
  }

  static Future<void> sendPushToUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    debugPrint('📲 Push to $userId: $title');
  }
}

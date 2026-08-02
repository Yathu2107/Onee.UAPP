import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

const oneeNotificationChannelId = 'onee_job_updates';
const oneeNotificationChannelName = 'Job updates';
const oneeNotificationChannelDesc = 'Status changes and messages for your jobs';

/// Shows a tray banner with Onee small icon + full-color large logo (right side).
/// Safe to call from a background isolate (no GetX).
Future<void> showOneePushBanner({
  required String title,
  required String body,
  int? jobId,
  String? type,
  int id = 0,
}) async {
  final plugin = FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@drawable/ic_stat_onee');
  const iosInit = DarwinInitializationSettings();

  await plugin.initialize(
    settings: const InitializationSettings(android: androidInit, iOS: iosInit),
  );

  final android = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      oneeNotificationChannelId,
      oneeNotificationChannelName,
      description: oneeNotificationChannelDesc,
      importance: Importance.high,
      playSound: true,
    ),
  );

  final payload = jsonEncode({
    'jobId': ?jobId,
    'type': ?type,
  });

  await plugin.show(
    id: id == 0 ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        oneeNotificationChannelId,
        oneeNotificationChannelName,
        channelDescription: oneeNotificationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@drawable/ic_stat_onee',
        largeIcon: const DrawableResourceAndroidBitmap('ic_notification_large'),
        color: const Color(0xFFEBB407),
        colorized: false,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: payload,
  );
}

/// Shows system / banner notifications (including while the app is foreground).
class LocalNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  int _id = 0;
  String? _lastDedupeKey;
  DateTime? _lastDedupeAt;

  Future<LocalNotificationService> init() async {
    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_onee');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onTap,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        oneeNotificationChannelId,
        oneeNotificationChannelName,
        description: oneeNotificationChannelDesc,
        importance: Importance.high,
        playSound: true,
      ),
    );
    await android?.requestNotificationsPermission();

    _ready = true;
    return this;
  }

  Future<void> show({
    required String title,
    required String body,
    int? jobId,
    String? type,
  }) async {
    if (!_ready) return;

    final dedupeKey = '${jobId ?? ''}|$title|$body';
    final now = DateTime.now();
    if (_lastDedupeKey == dedupeKey &&
        _lastDedupeAt != null &&
        now.difference(_lastDedupeAt!) < const Duration(seconds: 4)) {
      return;
    }
    _lastDedupeKey = dedupeKey;
    _lastDedupeAt = now;

    try {
      await showOneePushBanner(
        title: title,
        body: body,
        jobId: jobId,
        type: type,
        id: _id++,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Local notification failed: $e');
    }
  }

  void _onTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final jobId = int.tryParse(map['jobId']?.toString() ?? '');
      if (jobId != null) {
        Get.toNamed(AppRoutes.jobDetail, arguments: {'jobId': jobId});
      }
    } catch (_) {}
  }
}

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../notifications/local_notification_service.dart';

/// Runs when a data message arrives while the app is backgrounded.
/// When [message.notification] is set, Android/iOS already show the tray
/// banner (needed when the app is fully killed) — do not duplicate it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) {
    return;
  }

  final title = message.data['title']?.toString();
  final body = message.data['body']?.toString();
  if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
    return;
  }

  final jobIdRaw =
      message.data['jobId'] ?? message.data['fk_job_ID'] ?? message.data['job_id'];
  final jobId = int.tryParse(jobIdRaw?.toString() ?? '');

  try {
    await showOneePushBanner(
      title: title ?? 'Onee',
      body: body ?? '',
      jobId: jobId,
      type: message.data['type']?.toString(),
    );
  } catch (e) {
    if (kDebugMode) debugPrint('Background local notification failed: $e');
  }
}

/// FCM helper — no-ops gracefully if Firebase is not configured.
class FcmService extends GetxService {
  String? _token;
  String? get token => _token;

  String get platform => Platform.isIOS ? 'ios' : 'android';

  bool _ready = false;

  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _token = await messaging.getToken();
      _ready = true;

      // Foreground only — OS does not show notification payloads here.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _handleMessage(initial);
      }

      messaging.onTokenRefresh.listen((t) async {
        _token = t;
        await registerWithBackend();
      });

      if (kDebugMode) {
        debugPrint('FCM token: $_token');
      }
    } catch (e) {
      _ready = false;
      if (kDebugMode) {
        debugPrint(
          'FCM unavailable (add google-services.json / GoogleService-Info.plist): $e',
        );
      }
    }
  }

  Future<void> registerWithBackend() async {
    if (!_ready || _token == null || _token!.isEmpty) return;
    if (!Get.isRegistered<AuthRepository>()) return;
    try {
      await Get.find<AuthRepository>().registerDeviceToken(
        token: _token!,
        platform: platform,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('register-device-token failed: $e');
    }
  }

  Future<void> removeFromBackend() async {
    if (_token == null || _token!.isEmpty) return;
    if (!Get.isRegistered<AuthRepository>()) return;
    try {
      await Get.find<AuthRepository>().removeDeviceToken(
        token: _token!,
        platform: platform,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('remove device-token failed: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body =
        message.notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;

    final jobIdRaw =
        message.data['jobId'] ?? message.data['fk_job_ID'] ?? message.data['job_id'];
    final jobId = int.tryParse(jobIdRaw?.toString() ?? '');

    if (Get.isRegistered<LocalNotificationService>()) {
      Get.find<LocalNotificationService>().show(
        title: title ?? 'Onee',
        body: body ?? '',
        jobId: jobId,
        type: message.data['type']?.toString(),
      );
    } else {
      showOneePushBanner(
        title: title ?? 'Onee',
        body: body ?? '',
        jobId: jobId,
        type: message.data['type']?.toString(),
      );
    }
  }

  void _handleMessage(RemoteMessage message) {
    final jobIdRaw =
        message.data['jobId'] ?? message.data['fk_job_ID'] ?? message.data['job_id'];
    final jobId = int.tryParse(jobIdRaw?.toString() ?? '');
    if (jobId != null) {
      Get.toNamed(AppRoutes.jobDetail, arguments: {'jobId': jobId});
    }
  }
}

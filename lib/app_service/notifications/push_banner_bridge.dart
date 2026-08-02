import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../features/jobs/model/job_models.dart';
import '../notifications/local_notification_service.dart';
import '../notifications/notification_badge_service.dart';
import '../realtime/signalr_service.dart';
import '../storage/secure_storage_service.dart';

/// Turns SignalR job/chat events into system banner notifications.
class PushBannerBridge extends GetxService {
  Worker? _jobWorker;
  Worker? _chatWorker;
  String? _lastJobKey;
  int? _lastChatId;
  String? _currentUserId;

  void start() {
    if (!Get.isRegistered<SignalRService>()) return;
    final signalR = Get.find<SignalRService>();

    _jobWorker?.dispose();
    _chatWorker?.dispose();
    _loadCurrentUserId();

    _jobWorker = ever<JobDetail?>(signalR.jobUpdated, (detail) {
      if (detail == null) return;
      final key = '${detail.id}:${detail.status}';
      if (key == _lastJobKey) return;
      _lastJobKey = key;

      final status = detail.status?.trim();
      if (status == null || status.isEmpty) return;

      // Customer already sees the requesting UI — no tray for Offering.
      if (status.toLowerCase() == 'offering') {
        _refreshBadge();
        return;
      }

      _show(
        title: 'Job update',
        body: 'Your job is now $status.',
        jobId: detail.id,
        type: 'job_updated',
      );
      _refreshBadge();
    });

    _chatWorker = ever<JobChatMessage?>(signalR.chatMessage, (msg) {
      if (msg == null) return;
      if (msg.id == _lastChatId) return;
      _lastChatId = msg.id;

      // Never banner the sender for their own message.
      if (_isOwnMessage(msg.senderId)) return;

      final preview = msg.message.trim();
      if (preview.isEmpty) return;

      _show(
        title: 'New message',
        body: preview.length > 80 ? '${preview.substring(0, 80)}...' : preview,
        jobId: msg.jobId,
        type: 'chat_message',
      );
      _refreshBadge();
    });
  }

  Future<void> _loadCurrentUserId() async {
    try {
      if (!Get.isRegistered<SecureStorageService>()) return;
      final token = await Get.find<SecureStorageService>().getToken();
      if (token == null || token.isEmpty) return;
      final decoded = JwtDecoder.decode(token);
      _currentUserId = (decoded['uid']?.toString() ??
              decoded['sub']?.toString() ??
              decoded['nameid']?.toString() ??
              '')
          .trim();
    } catch (_) {
      _currentUserId = null;
    }
  }

  bool _isOwnMessage(String senderId) {
    final uid = _currentUserId?.trim() ?? '';
    final sender = senderId.trim();
    if (uid.isEmpty || sender.isEmpty) return false;
    return uid.toLowerCase() == sender.toLowerCase();
  }

  void _show({
    required String title,
    required String body,
    required int jobId,
    required String type,
  }) {
    if (!Get.isRegistered<LocalNotificationService>()) return;
    Get.find<LocalNotificationService>().show(
      title: title,
      body: body,
      jobId: jobId,
      type: type,
    );
  }

  void _refreshBadge() {
    if (Get.isRegistered<NotificationBadgeService>()) {
      Get.find<NotificationBadgeService>().refresh();
    }
  }

  @override
  void onClose() {
    _jobWorker?.dispose();
    _chatWorker?.dispose();
    super.onClose();
  }
}

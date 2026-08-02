import 'package:get/get.dart';

import '../../features/jobs/model/job_models.dart';
import '../notifications/local_notification_service.dart';
import '../notifications/notification_badge_service.dart';
import '../realtime/signalr_service.dart';

/// Turns SignalR job/chat events into system banner notifications.
class PushBannerBridge extends GetxService {
  Worker? _jobWorker;
  Worker? _chatWorker;
  String? _lastJobKey;
  int? _lastChatId;

  void start() {
    if (!Get.isRegistered<SignalRService>()) return;
    final signalR = Get.find<SignalRService>();

    _jobWorker?.dispose();
    _chatWorker?.dispose();

    _jobWorker = ever<JobDetail?>(signalR.jobUpdated, (detail) {
      if (detail == null) return;
      final key = '${detail.id}:${detail.status}';
      if (key == _lastJobKey) return;
      _lastJobKey = key;

      final status = detail.status?.trim();
      if (status == null || status.isEmpty) return;

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

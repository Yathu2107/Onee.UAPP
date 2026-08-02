import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app_service/network/api_response.dart';
import '../../../app_service/realtime/signalr_service.dart';
import '../../../common_widgets/app_snackbar.dart';
import '../../../utils/job_statuses.dart';
import '../model/job_models.dart';
import '../repository/job_repository.dart';
import 'cancel_reason_sheet.dart';

class JobDetailController extends GetxController {
  JobDetailController(this._jobRepository);

  final JobRepository _jobRepository;

  final isLoading = false.obs;
  final isCancelling = false.obs;
  final job = Rxn<JobDetail>();
  final error = RxnString();
  final offerCountdown = RxnString();

  late final int jobId;
  Worker? _jobUpdatedWorker;
  Timer? _countdownTimer;
  Timer? _offeringPoll;
  bool _navigatingAway = false;
  bool _reloadAfterExpire = false;

  @override
  void onInit() {
    super.onInit();
    jobId = _parseJobId();
  }

  int _parseJobId() {
    final args = Get.arguments;
    if (args is int) return args;
    if (args is Map) {
      final raw = args['jobId'] ?? args['id'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  @override
  void onReady() {
    super.onReady();
    if (jobId <= 0) {
      error.value = 'Invalid job.';
      return;
    }
    load();
    _joinAndListen();
  }

  Future<void> _joinAndListen() async {
    if (!Get.isRegistered<SignalRService>()) return;
    final signalR = Get.find<SignalRService>();
    await signalR.connect();
    await signalR.joinJob(jobId);

    _jobUpdatedWorker = ever<JobDetail?>(signalR.jobUpdated, (detail) {
      if (detail == null || detail.id != jobId) return;
      job.value = detail;
      _startOfferCountdown();
      _onStatusChanged(detail);
    });

    // Safety net while waiting for a worker: poll if SignalR is quiet.
    _startOfferingPoll();
  }

  void _startOfferingPoll() {
    _offeringPoll?.cancel();
    _offeringPoll = Timer.periodic(const Duration(seconds: 4), (_) async {
      final status = job.value?.status;
      if (!JobStatuses.isOffering(status)) {
        _offeringPoll?.cancel();
        _offeringPoll = null;
        return;
      }
      try {
        final response = await _jobRepository.getJob(jobId);
        final detail = response.result;
        if (detail == null) return;
        if (detail.status == job.value?.status &&
            detail.workerId == job.value?.workerId) {
          return;
        }
        job.value = detail;
        _startOfferCountdown();
        _onStatusChanged(detail);
        if (!JobStatuses.isOffering(detail.status)) {
          _offeringPoll?.cancel();
          _offeringPoll = null;
        }
      } catch (_) {}
    });
  }

  void _onStatusChanged(JobDetail detail) {
    if (_navigatingAway) return;

    // No snackbars here — PushBannerBridge / FCM already show the notification.
    if (JobStatuses.isFailed(detail.status)) {
      _goHomeAfterFailure();
    }
  }

  void _goHomeAfterFailure() {
    if (_navigatingAway) return;
    _navigatingAway = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (Get.isRegistered<JobDetailController>() &&
          Get.find<JobDetailController>() == this) {
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final response = await _jobRepository.getJob(jobId);
      final detail = response.result;
      job.value = detail;
      _startOfferCountdown();
      if (detail != null && JobStatuses.isFailed(detail.status)) {
        _goHomeAfterFailure();
      }
    } on ApiException catch (e) {
      error.value = e.message;
      AppSnackbar.error(e.message);
    } catch (_) {
      error.value = 'Failed to load job.';
      AppSnackbar.error('Failed to load job.');
    } finally {
      isLoading.value = false;
    }
  }

  void _startOfferCountdown() {
    _countdownTimer?.cancel();
    offerCountdown.value = null;
    final detail = job.value;
    if (!JobStatuses.isOffering(detail?.status) ||
        detail?.offerExpiresAt == null) {
      return;
    }
    _reloadAfterExpire = false;

    void tick() {
      final current = job.value;
      if (current?.offerExpiresAt == null) return;
      final expires = current!.offerExpiresAt!.toLocal();
      final remaining = expires.difference(DateTime.now());
      if (remaining.isNegative) {
        offerCountdown.value = 'Expired';
        _countdownTimer?.cancel();
        if (!_reloadAfterExpire) {
          _reloadAfterExpire = true;
          load();
        }
        return;
      }
      final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
      final h = remaining.inHours;
      offerCountdown.value =
          h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
    }

    tick();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<void> cancelJob({bool goHomeAfter = true}) async {
    final reason = await _pickCancelReason();
    if (reason == null) return;
    if (reason.trim().isEmpty) {
      AppSnackbar.info('Please provide a cancel reason.');
      return;
    }

    isCancelling.value = true;
    try {
      final response = await _jobRepository.cancelJob(jobId, reason.trim());
      job.value = response.result;
      if (goHomeAfter) {
        Get.offAllNamed(AppRoutes.home);
      }
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('Failed to cancel job.');
    } finally {
      isCancelling.value = false;
    }
  }

  Future<String?> _pickCancelReason() async {
    const presets = <String>[
      'Changed my mind',
      'Found another solution',
      'Wrong problem description',
      'Taking too long',
      'Booked by mistake',
      'Other',
    ];

    return Get.bottomSheet<String>(
      CancelReasonSheet(presets: presets),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> goChat() async {
    await Get.toNamed(AppRoutes.jobChat, arguments: {'jobId': jobId});
    await load();
  }

  Future<void> goRate() async {
    await Get.toNamed(AppRoutes.rateWorker, arguments: {'jobId': jobId});
    await load();
  }

  Future<void> goComplaint() async {
    await Get.toNamed(AppRoutes.createComplaint, arguments: {'jobId': jobId});
    await load();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _offeringPoll?.cancel();
    _jobUpdatedWorker?.dispose();
    if (Get.isRegistered<SignalRService>() && jobId > 0) {
      Get.find<SignalRService>().leaveJob(jobId);
    }
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app_service/network/api_response.dart';
import '../../../common_widgets/app_snackbar.dart';
import '../repository/job_repository.dart';

class RateWorkerController extends GetxController {
  RateWorkerController(this._jobRepository);

  final JobRepository _jobRepository;

  final feedbackController = TextEditingController();
  final rating = 0.obs;
  final isSubmitting = false.obs;
  final workerName = 'your worker'.obs;
  final selectedQuickTags = <String>[].obs;

  static const quickTags = <String>[
    'On time',
    'Professional',
    'Friendly',
    'Skilled',
    'Good value',
    'Would hire again',
  ];

  late final int jobId;

  String get ratingLabel {
    switch (rating.value) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent';
      default:
        return 'Tap a star to rate';
    }
  }

  @override
  void onInit() {
    super.onInit();
    jobId = _parseJobId();
  }

  @override
  void onReady() {
    super.onReady();
    _loadWorkerName();
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

  Future<void> _loadWorkerName() async {
    if (jobId <= 0) return;
    try {
      final response = await _jobRepository.getJob(jobId);
      final name = response.result?.workerName?.trim();
      if (name != null && name.isNotEmpty) {
        workerName.value = name;
      }
    } catch (_) {}
  }

  void setRating(int value) => rating.value = value;

  void toggleTag(String tag) {
    if (selectedQuickTags.contains(tag)) {
      selectedQuickTags.remove(tag);
    } else {
      selectedQuickTags.add(tag);
    }
  }

  String _composeFeedback() {
    final typed = feedbackController.text.trim();
    final tags = selectedQuickTags.toList();
    if (tags.isEmpty) return typed;
    final tagLine = tags.join(' · ');
    if (typed.isEmpty) return tagLine;
    return '$tagLine\n$typed';
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (jobId <= 0) {
      AppSnackbar.error('Invalid job.');
      return;
    }
    if (rating.value < 1 || rating.value > 5) {
      AppSnackbar.info('Please select a star rating.');
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await _jobRepository.rateJob(
        jobId: jobId,
        rating: rating.value,
        feedback: _composeFeedback(),
      );
      final message = response.text.isNotEmpty
          ? response.text
          : 'Thanks for your rating.';
      Get.offAllNamed(AppRoutes.home);
      AppSnackbar.success(message);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('Failed to submit rating.');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    feedbackController.dispose();
    super.onClose();
  }
}

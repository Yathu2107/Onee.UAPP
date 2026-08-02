import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_service/network/api_response.dart';
import '../../../common_widgets/app_snackbar.dart';
import '../repository/complaint_repository.dart';

class ComplaintController extends GetxController {
  ComplaintController(this._complaintRepository);

  final ComplaintRepository _complaintRepository;

  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final isSubmitting = false.obs;

  late final int jobId;

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

  String? validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) return 'Subject is required';
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) return 'Please add more detail';
    return null;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (jobId <= 0) {
      AppSnackbar.error('Invalid job.');
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSubmitting.value = true;
    try {
      final response = await _complaintRepository.create(
        jobId: jobId,
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
      );
      AppSnackbar.success(
        response.text.isNotEmpty
            ? response.text
            : 'Complaint submitted.',
      );
      Get.back(result: true);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('Failed to submit complaint.');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

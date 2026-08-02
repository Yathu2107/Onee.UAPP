import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.nearBlack,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  static void error(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.nearBlack,
      colorText: AppColors.cream,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  static void info(String message) {
    Get.snackbar(
      'Onee',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.mutedBrown,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

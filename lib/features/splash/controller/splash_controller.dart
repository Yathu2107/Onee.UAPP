import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app_service/network/api_response.dart';
import '../../../app_service/storage/secure_storage_service.dart';
import '../../auth/repository/auth_repository.dart';

class SplashController extends GetxController {
  SplashController(this._authRepository, this._storage);

  final AuthRepository _authRepository;
  final SecureStorageService _storage;

  final isChecking = true.obs;
  bool _navigated = false;

  /// Hard ceiling so splash never hangs on storage/network stalls.
  static const _sessionRestoreTimeout = Duration(seconds: 8);

  @override
  void onReady() {
    super.onReady();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await _restoreSession().timeout(_sessionRestoreTimeout);
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('Splash session restore timed out: $e');
      }
      _goToPhoneLogin();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Splash bootstrap failed: $e');
      }
      _goToPhoneLogin();
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> _restoreSession() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      _goToPhoneLogin();
      return;
    }

    try {
      final response = await _authRepository.getLoggedUserDetails().timeout(
        const Duration(seconds: 6),
      );
      final user = response.result;

      if (user != null && user.hasName) {
        _navigateOnce(AppRoutes.home);
      } else {
        _navigateOnce(
          AppRoutes.completeRegistration,
          arguments: {
            if (user?.phoneNumber != null) 'phone': user!.phoneNumber,
          },
        );
      }
    } on ApiException catch (e) {
      await _storage.clearTokens();
      if (kDebugMode) {
        debugPrint('Splash API error: ${e.code} ${e.message}');
      }
      _goToPhoneLogin();
    } on TimeoutException {
      _goToPhoneLogin();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Splash unexpected error: $e');
      }
      await _storage.clearTokens();
      _goToPhoneLogin();
    }
  }

  void _goToPhoneLogin() => _navigateOnce(AppRoutes.phoneLogin);

  void _navigateOnce(String route, {Map<String, dynamic>? arguments}) {
    if (_navigated) return;
    _navigated = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == route) return;
      Get.offAllNamed(route, arguments: arguments);
    });
  }
}

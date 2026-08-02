import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app_service/network/api_response.dart';
import '../../../app_service/push/fcm_service.dart';
import '../../../app_service/realtime/signalr_service.dart';
import '../../../common_widgets/app_snackbar.dart';
import '../../auth/model/auth_models.dart';
import '../../auth/repository/auth_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._authRepository);

  final AuthRepository _authRepository;

  final isLoading = false.obs;
  final isLoggingOut = false.obs;
  final user = Rxn<UserDetails>();

  @override
  void onReady() {
    super.onReady();
    loadUser();
  }

  Future<void> loadUser() async {
    isLoading.value = true;
    try {
      final response = await _authRepository.getLoggedUserDetails();
      user.value = response.result;
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
      if (e.statusCode == 401 || e.statusCode == 404) {
        await _authRepository.clearSession();
        Get.offAllNamed(AppRoutes.phoneLogin);
      }
    } catch (_) {
      AppSnackbar.error('Failed to load profile.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goEditProfile() async {
    await Get.toNamed(AppRoutes.editProfile);
    await loadUser();
  }

  Future<void> goAddresses() async {
    await Get.toNamed(AppRoutes.addresses);
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      if (Get.isRegistered<FcmService>()) {
        await Get.find<FcmService>().removeFromBackend();
      }

      try {
        await _authRepository.logout();
      } catch (_) {
        // Always clear local session even if API fails.
      }

      if (Get.isRegistered<SignalRService>()) {
        await Get.find<SignalRService>().disconnect();
      }

      await _authRepository.clearSession();
      Get.offAllNamed(AppRoutes.phoneLogin);
    } finally {
      isLoggingOut.value = false;
    }
  }
}

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app_service/network/api_response.dart';
import '../../../app_service/push/fcm_service.dart';
import '../../../app_service/realtime/signalr_service.dart';
import '../../../common_widgets/app_snackbar.dart';
import '../../../utils/job_statuses.dart';
import '../../addresses/model/address_models.dart';
import '../../addresses/repository/address_repository.dart';
import '../../auth/model/auth_models.dart';
import '../../auth/repository/auth_repository.dart';
import '../../jobs/model/job_models.dart';
import '../../jobs/repository/job_repository.dart';

class HomeController extends GetxController {
  HomeController(
    this._authRepository,
    this._jobRepository,
    this._addressRepository,
  );

  final AuthRepository _authRepository;
  final JobRepository _jobRepository;
  final AddressRepository _addressRepository;

  final isLoading = false.obs;
  final user = Rxn<UserDetails>();
  final selectedAddress = Rxn<SavedAddress>();
  final recentJobs = <JobListItem>[].obs;
  final jobsError = RxnString();

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      loadUser(),
      loadRecentJobs(),
      loadDefaultAddress(),
    ]);

    try {
      if (Get.isRegistered<SignalRService>()) {
        await Get.find<SignalRService>().connect();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<FcmService>()) {
        await Get.find<FcmService>().registerWithBackend();
      }
    } catch (_) {}
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadUser(),
      loadRecentJobs(),
      loadDefaultAddress(),
    ]);
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

  Future<void> loadDefaultAddress() async {
    try {
      final response = await _addressRepository.list();
      final list = response.result ?? <SavedAddress>[];
      if (list.isEmpty) {
        selectedAddress.value = null;
        return;
      }
      selectedAddress.value = list.firstWhere(
        (a) => a.isDefault,
        orElse: () => list.first,
      );
    } catch (_) {
      // Keep previous selection if refresh fails.
    }
  }

  Future<void> loadRecentJobs() async {
    jobsError.value = null;
    try {
      final response = await _jobRepository.getMyJobs();
      final jobs = response.result ?? <JobListItem>[];
      recentJobs.assignAll(
        jobs.where((j) => JobStatuses.isActive(j.status)).take(5).toList(),
      );
    } on ApiException catch (e) {
      jobsError.value = e.message;
      AppSnackbar.error(e.message);
    } catch (_) {
      jobsError.value = 'Failed to load recent jobs.';
      AppSnackbar.error('Failed to load recent jobs.');
    }
  }

  void goCreateJob() => Get.toNamed(AppRoutes.createJobChooser);

  Future<void> goAddresses() async {
    await Get.toNamed(AppRoutes.addresses);
    await loadDefaultAddress();
  }

  Future<void> openJob(int jobId) async {
    await Get.toNamed(AppRoutes.jobDetail, arguments: {'jobId': jobId});
    await refreshAll();
  }
}

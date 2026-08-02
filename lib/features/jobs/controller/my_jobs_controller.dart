import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app_service/network/api_response.dart';
import '../../../app_service/realtime/signalr_service.dart';
import '../../../common_widgets/app_snackbar.dart';
import '../../../utils/job_statuses.dart';
import '../model/job_models.dart';
import '../repository/job_repository.dart';

enum MyJobsFilter { all, active, completed, cancelled }

class MyJobsController extends GetxController {
  MyJobsController(this._jobRepository);

  final JobRepository _jobRepository;

  final isLoading = false.obs;
  final filter = MyJobsFilter.all.obs;
  final allJobs = <JobListItem>[].obs;
  final error = RxnString();

  Worker? _jobUpdatedWorker;

  List<JobListItem> filteredJobsFor(MyJobsFilter selected) {
    // Touch length so Obx always tracks RxList mutations.
    final jobs = allJobs.toList();
    switch (selected) {
      case MyJobsFilter.all:
        return jobs;
      case MyJobsFilter.active:
        return jobs.where((j) => JobStatuses.isActive(j.status)).toList();
      case MyJobsFilter.completed:
        return jobs.where((j) => JobStatuses.isCompleted(j.status)).toList();
      case MyJobsFilter.cancelled:
        return jobs
            .where((j) => JobStatuses.isCancelledGroup(j.status))
            .toList();
    }
  }

  @override
  void onReady() {
    super.onReady();
    load();
    _listenSignalR();
  }

  void _listenSignalR() {
    if (!Get.isRegistered<SignalRService>()) return;
    final signalR = Get.find<SignalRService>();
    _jobUpdatedWorker = ever<JobDetail?>(signalR.jobUpdated, (detail) {
      if (detail == null) return;
      load(silent: true);
    });
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = null;
    try {
      final response = await _jobRepository.getMyJobs();
      allJobs.assignAll(response.result ?? <JobListItem>[]);
    } on ApiException catch (e) {
      error.value = e.message;
      if (!silent) AppSnackbar.error(e.message);
    } catch (_) {
      error.value = 'Failed to load jobs.';
      if (!silent) AppSnackbar.error('Failed to load jobs.');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> refreshList() => load();

  void setFilter(MyJobsFilter value) => filter.value = value;

  Future<void> openJob(int jobId) async {
    await Get.toNamed(AppRoutes.jobDetail, arguments: {'jobId': jobId});
    await load(silent: true);
  }

  @override
  void onClose() {
    _jobUpdatedWorker?.dispose();
    super.onClose();
  }
}

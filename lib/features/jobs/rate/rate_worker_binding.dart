import 'package:get/get.dart';

import '../../../app_service/network/dio_client.dart';
import '../repository/job_repository.dart';
import 'rate_worker_controller.dart';

class RateWorkerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<JobRepository>()) {
      Get.lazyPut<JobRepository>(
        () => JobRepository(Get.find<DioClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<RateWorkerController>(
      () => RateWorkerController(Get.find<JobRepository>()),
    );
  }
}

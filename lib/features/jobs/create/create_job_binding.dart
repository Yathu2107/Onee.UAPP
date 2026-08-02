import 'package:get/get.dart';

import '../../../app_service/network/dio_client.dart';
import '../../addresses/repository/address_repository.dart';
import '../repository/job_repository.dart';
import 'create_job_controller.dart';

class CreateJobBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<JobRepository>()) {
      Get.lazyPut<JobRepository>(
        () => JobRepository(Get.find<DioClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
        () => AddressRepository(Get.find<DioClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CreateJobController>()) {
      Get.put<CreateJobController>(
        CreateJobController(
          Get.find<JobRepository>(),
          Get.find<AddressRepository>(),
        ),
      );
    }
  }
}

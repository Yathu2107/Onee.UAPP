import 'package:get/get.dart';

import '../../../app_service/network/dio_client.dart';
import '../repository/complaint_repository.dart';
import 'complaint_controller.dart';

class ComplaintBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ComplaintRepository>()) {
      Get.lazyPut<ComplaintRepository>(
        () => ComplaintRepository(Get.find<DioClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<ComplaintController>(
      () => ComplaintController(Get.find<ComplaintRepository>()),
    );
  }
}

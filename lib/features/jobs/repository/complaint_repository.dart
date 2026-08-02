import 'package:dio/dio.dart';

import '../../../app_service/network/api_client_mixin.dart';
import '../../../app_service/network/api_response.dart';
import '../../../app_service/network/dio_client.dart';

class ComplaintRepository with ApiClientMixin {
  ComplaintRepository(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<ApiResponse<String>> create({
    required int jobId,
    required String subject,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/complaints/create',
        data: {
          'jobId': jobId,
          'subject': subject,
          'description': description,
        },
      );
      return parseMessageResponse(response, (raw) => raw?.toString() ?? 'OK');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

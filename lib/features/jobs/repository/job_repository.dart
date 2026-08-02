import 'package:dio/dio.dart';

import '../../../app_service/network/api_client_mixin.dart';
import '../../../app_service/network/api_response.dart';
import '../../../app_service/network/dio_client.dart';
import '../../../utils/json_helpers.dart';
import '../model/job_models.dart';

class JobRepository with ApiClientMixin {
  JobRepository(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<ApiResponse<JobMatchResult>> findWorkers(String text) async {
    try {
      final response = await _dio.post(
        '/jobs/find-workers',
        data: {'text': text},
      );
      return parseMessageResponse(
        response,
        (raw) => JobMatchResult.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<List<JobCategory>>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      return parseMessageResponse(
        response,
        (raw) => JsonHelpers.parseObjectList(raw, JobCategory.fromJson),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<JobMatchResult>> findWorkersByCategory(
    int categoryId,
  ) async {
    try {
      final response = await _dio.post(
        '/jobs/find-workers-by-category',
        data: {'categoryId': categoryId},
      );
      return parseMessageResponse(
        response,
        (raw) => JobMatchResult.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<JobDetail>> createJob({
    required String text,
    required List<String> workerIds,
    int? addressId,
  }) async {
    try {
      final response = await _dio.post(
        '/jobs/create',
        data: {
          'text': text,
          'workerIds': workerIds,
          'addressId': ?addressId,
        },
      );
      return parseMessageResponse(
        response,
        (raw) => JobDetail.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<List<JobListItem>>> getMyJobs() async {
    try {
      final response = await _dio.get('/jobs/mine');
      return parseMessageResponse(
        response,
        (raw) => JsonHelpers.parseObjectList(raw, JobListItem.fromJson),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<JobDetail>> getJob(int id) async {
    try {
      final response = await _dio.get('/jobs/$id');
      return parseMessageResponse(
        response,
        (raw) => JobDetail.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<JobDetail>> cancelJob(int id, String reason) async {
    try {
      final response = await _dio.post(
        '/jobs/$id/cancel',
        data: {'reason': reason},
      );
      return parseMessageResponse(
        response,
        (raw) => JobDetail.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<List<JobChatMessage>>> getChat(int jobId) async {
    try {
      final response = await _dio.get('/jobs/$jobId/chat');
      return parseMessageResponse(
        response,
        (raw) => JsonHelpers.parseObjectList(raw, JobChatMessage.fromJson),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<JobChatMessage>> sendChat(int jobId, String message) async {
    try {
      final response = await _dio.post(
        '/jobs/$jobId/chat',
        data: {'message': message},
      );
      return parseMessageResponse(
        response,
        (raw) => JobChatMessage.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ApiResponse<JobRating>> rateJob({
    required int jobId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final response = await _dio.post(
        '/jobs/$jobId/rating',
        data: {
          'rating': rating,
          'feedback': feedback ?? '',
        },
      );
      return parseMessageResponse(
        response,
        (raw) => JobRating.fromJson(Map<String, dynamic>.from(raw as Map)),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

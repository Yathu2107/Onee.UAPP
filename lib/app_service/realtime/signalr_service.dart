import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../features/jobs/model/job_models.dart';
import '../storage/secure_storage_service.dart';

/// SignalR client for `{BASE_URL}/hubs/job`.
class SignalRService extends GetxService {
  HubConnection? _connection;
  final SecureStorageService _storage;

  final jobUpdated = Rxn<JobDetail>();
  final chatMessage = Rxn<JobChatMessage>();

  StreamSubscription? _jobUpdatedSub;
  StreamSubscription? _chatSub;

  SignalRService(this._storage);

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return;

    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://localhost:7076';
    final hubUrl = '$baseUrl/hubs/job';

    try {
      await disconnect();

      _connection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              skipNegotiation: false,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _connection!.on('JobUpdated', _onJobUpdated);
      _connection!.on('ChatMessage', _onChatMessage);
      // JobOffer is worker-only; ignore in User app.

      await _connection!.start();
      if (kDebugMode) {
        debugPrint('SignalR connected to $hubUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SignalR connect failed: $e');
      }
    }
  }

  Future<void> disconnect() async {
    try {
      await _connection?.stop();
    } catch (_) {}
    _connection = null;
  }

  Future<void> joinJob(int jobId) async {
    if (!isConnected) await connect();
    try {
      await _connection?.invoke('JoinJob', args: <Object>[jobId]);
    } catch (e) {
      if (kDebugMode) debugPrint('JoinJob failed: $e');
    }
  }

  Future<void> leaveJob(int jobId) async {
    try {
      await _connection?.invoke('LeaveJob', args: <Object>[jobId]);
    } catch (e) {
      if (kDebugMode) debugPrint('LeaveJob failed: $e');
    }
  }

  void _onJobUpdated(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final raw = args.first;
    if (raw is! Map) return;
    try {
      final detail = JobDetail.fromJson(Map<String, dynamic>.from(raw));
      jobUpdated.value = detail;
    } catch (e) {
      if (kDebugMode) debugPrint('JobUpdated parse error: $e');
    }
  }

  void _onChatMessage(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final raw = args.first;
    if (raw is! Map) return;
    try {
      chatMessage.value = JobChatMessage.fromJson(
        Map<String, dynamic>.from(raw),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('ChatMessage parse error: $e');
    }
  }

  @override
  void onClose() {
    _jobUpdatedSub?.cancel();
    _chatSub?.cancel();
    disconnect();
    super.onClose();
  }
}

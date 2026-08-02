import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app_service/network/api_response.dart';
import '../../../common_widgets/app_snackbar.dart';
import '../../addresses/model/address_models.dart';
import '../../addresses/repository/address_repository.dart';
import '../model/job_models.dart';
import '../repository/job_repository.dart';

class CreateJobController extends GetxController {
  CreateJobController(this._jobRepository, this._addressRepository);

  final JobRepository _jobRepository;
  final AddressRepository _addressRepository;
  final SpeechToText _speech = SpeechToText();

  final problemController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isFinding = false.obs;
  final isCreating = false.obs;
  final isLoadingAddresses = false.obs;
  final isListening = false.obs;
  final speechAvailable = false.obs;
  final liveSpeech = ''.obs;

  final problemText = ''.obs;
  final matchResult = Rxn<JobMatchResult>();
  final selectedWorkerIds = <String>[].obs;
  final selectedAddressId = RxnInt();
  final addresses = <SavedAddress>[].obs;
  final categories = <JobCategory>[].obs;
  final isLoadingCategories = false.obs;
  final isCategoryBooking = false.obs;
  final categoriesError = RxnString();

  String _textBeforeListen = '';
  bool _speechReady = false;

  @override
  void onInit() {
    super.onInit();
    problemController.addListener(_syncProblemText);
    _initSpeech();
  }

  void _syncProblemText() {
    problemText.value = problemController.text;
  }

  Future<void> _initSpeech() async {
    try {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (error) {
          isListening.value = false;
          if (error.errorMsg != 'error_speech_timeout' &&
              error.errorMsg != 'error_no_match') {
            AppSnackbar.error('Voice input failed. Try again.');
          }
        },
      );
      speechAvailable.value = _speechReady;
    } catch (_) {
      speechAvailable.value = false;
    }
  }

  Future<void> toggleVoiceInput() async {
    if (isListening.value) {
      await stopVoiceInput();
      return;
    }
    await startVoiceInput();
  }

  Future<void> startVoiceInput() async {
    if (!_speechReady) {
      await _initSpeech();
    }
    if (!_speechReady) {
      AppSnackbar.error(
        'Speech recognition is not available on this device.',
      );
      return;
    }

    _textBeforeListen = problemController.text.trim();
    if (_textBeforeListen.isNotEmpty) {
      _textBeforeListen = '$_textBeforeListen ';
    }
    liveSpeech.value = '';
    isListening.value = true;

    try {
      await _speech.listen(
        onResult: (result) {
          liveSpeech.value = result.recognizedWords;
          final next =
              '$_textBeforeListen${result.recognizedWords}'.trimLeft();
          problemController.value = TextEditingValue(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      isListening.value = false;
      AppSnackbar.error('Could not start voice input.');
    }
  }

  Future<void> stopVoiceInput() async {
    try {
      await _speech.stop();
    } catch (_) {}
    isListening.value = false;
  }

  String? validateProblem(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Describe the problem';
    if (text.length < 8) return 'Please add a bit more detail';
    return null;
  }

  Future<void> findWorkers() async {
    if (isFinding.value) return;
    if (isListening.value) await stopVoiceInput();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final text = problemController.text.trim();
    problemText.value = text;
    isCategoryBooking.value = false;
    isFinding.value = true;
    try {
      final response = await _jobRepository.findWorkers(text);
      matchResult.value = response.result;
      selectedWorkerIds.clear();

      final workers = response.result?.workers ?? const <JobMatchWorker>[];
      if (workers.isEmpty) {
        AppSnackbar.info('No matching workers found nearby. Try rephrasing.');
      }

      await loadAddresses();
      Get.toNamed(AppRoutes.createJobWorkers);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('Failed to find workers.');
    } finally {
      isFinding.value = false;
    }
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    categoriesError.value = null;
    try {
      final response = await _jobRepository.getCategories();
      categories.assignAll(response.result ?? <JobCategory>[]);
      if (categories.isEmpty) {
        categoriesError.value = 'No categories available right now.';
      }
    } on ApiException catch (e) {
      categoriesError.value = e.message;
      AppSnackbar.error(e.message);
    } catch (_) {
      categoriesError.value = 'Failed to load categories.';
      AppSnackbar.error('Failed to load categories.');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> findWorkersByCategory(JobCategory category) async {
    if (isFinding.value) return;
    if (category.id <= 0) {
      AppSnackbar.error('Invalid category.');
      return;
    }

    isFinding.value = true;
    try {
      await loadAddresses();
      final defaults = addresses.where((a) => a.isDefault).toList();
      if (defaults.isEmpty) {
        AppSnackbar.info(
          'Add a default saved address before browsing workers by category.',
        );
        return;
      }
      selectedAddressId.value = defaults.first.id;

      final response =
          await _jobRepository.findWorkersByCategory(category.id);
      final result = response.result;
      matchResult.value = JobMatchResult(
        predictedCategory: result?.predictedCategory ?? category.categoryName,
        confidence: result?.confidence,
        categoryId: result?.categoryId ?? category.id,
        categoryName: result?.categoryName ?? category.categoryName,
        workers: result?.workers ?? const [],
      );
      selectedWorkerIds.clear();
      isCategoryBooking.value = true;
      problemController.text = '';
      problemText.value = '';

      final workers = matchResult.value?.workers ?? const <JobMatchWorker>[];
      if (workers.isEmpty) {
        AppSnackbar.info(
          'No nearby workers for ${category.categoryName}. Try another category.',
        );
        return;
      }

      Get.toNamed(AppRoutes.createJobWorkers);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('Failed to find workers.');
    } finally {
      isFinding.value = false;
    }
  }

  void toggleWorker(String workerId) {
    if (selectedWorkerIds.contains(workerId)) {
      selectedWorkerIds.remove(workerId);
    } else {
      selectedWorkerIds.add(workerId);
    }
  }

  bool isWorkerSelected(String workerId) =>
      selectedWorkerIds.contains(workerId);

  int workerOrder(String workerId) {
    final index = selectedWorkerIds.indexOf(workerId);
    return index < 0 ? 0 : index + 1;
  }

  Future<void> loadAddresses() async {
    isLoadingAddresses.value = true;
    try {
      final response = await _addressRepository.list();
      final list = response.result ?? <SavedAddress>[];
      addresses.assignAll(list);

      if (selectedAddressId.value == null && list.isNotEmpty) {
        final defaults = list.where((a) => a.isDefault).toList();
        selectedAddressId.value =
            defaults.isNotEmpty ? defaults.first.id : list.first.id;
      }
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('Failed to load addresses.');
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  void selectAddress(int? id) => selectedAddressId.value = id;

  Future<void> goAddAddress() async {
    final result = await Get.toNamed(
      AppRoutes.addressForm,
      arguments: {'returnResult': true},
    );
    if (result is SavedAddress) {
      await loadAddresses();
      selectedAddressId.value = result.id;
    } else if (result != null) {
      await loadAddresses();
    }
  }

  bool validateWorkerStep() {
    if (selectedWorkerIds.isEmpty) {
      AppSnackbar.info('Select at least one worker.');
      return false;
    }
    if (selectedAddressId.value == null) {
      AppSnackbar.info('Select a saved address for this job.');
      return false;
    }
    return true;
  }

  void goConfirm() {
    if (!validateWorkerStep()) return;
    Get.toNamed(AppRoutes.createJobConfirm);
  }

  List<JobMatchWorker> get selectedWorkers {
    final workers = matchResult.value?.workers ?? const <JobMatchWorker>[];
    final byId = {for (final w in workers) w.id: w};
    return selectedWorkerIds
        .map((id) => byId[id])
        .whereType<JobMatchWorker>()
        .toList();
  }

  SavedAddress? get selectedAddress {
    final id = selectedAddressId.value;
    if (id == null) return null;
    for (final address in addresses) {
      if (address.id == id) return address;
    }
    return null;
  }

  Future<void> createJob() async {
    if (isCreating.value) return;
    if (!validateWorkerStep()) return;

    var text = problemText.value.trim();
    if (text.isEmpty && isCategoryBooking.value) {
      final category = matchResult.value?.categoryName?.trim();
      text = (category != null && category.isNotEmpty)
          ? 'Need help with $category'
          : 'Need help';
      problemText.value = text;
      problemController.text = text;
    }
    if (text.isEmpty) {
      AppSnackbar.info('Add a short description for the job.');
      return;
    }

    isCreating.value = true;
    try {
      final response = await _jobRepository.createJob(
        text: text,
        workerIds: List<String>.from(selectedWorkerIds),
        addressId: selectedAddressId.value,
      );
      final job = response.result;
      if (job == null) {
        AppSnackbar.error('Job created but details were missing.');
        return;
      }
      Get.offNamedUntil(
        AppRoutes.jobDetail,
        (route) =>
            route.settings.name == AppRoutes.home || route.isFirst,
        arguments: {'jobId': job.id},
      );
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('Failed to create job.');
    } finally {
      isCreating.value = false;
    }
  }

  @override
  void onClose() {
    problemController.removeListener(_syncProblemText);
    problemController.dispose();
    _speech.cancel();
    super.onClose();
  }
}

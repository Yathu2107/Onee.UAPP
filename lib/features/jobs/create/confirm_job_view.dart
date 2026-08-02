import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../common_widgets/primary_button.dart';
import '../../addresses/model/address_models.dart';
import '../model/job_models.dart';
import 'create_job_controller.dart';

class ConfirmJobView extends GetView<CreateJobController> {
  const ConfirmJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final match = controller.matchResult.value;
              final workers = controller.selectedWorkers;
              final address = controller.selectedAddress;
              final category = match?.categoryName ??
                  match?.predictedCategory ??
                  '—';
              final confidence = match?.confidence;
              final pct = confidence == null
                  ? null
                  : (confidence <= 1 ? confidence * 100 : confidence);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeroHeader(
                      workerCount: workers.length,
                      category: category,
                      confidencePct: pct,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Obx(
                      () => _ProblemSection(
                        controller: controller,
                        editable: controller.isCategoryBooking.value,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _AddressSection(address: address),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: _SectionLabel(
                        title: 'Offer order',
                        subtitle: workers.isEmpty
                            ? 'No workers selected'
                            : '${workers.length} worker${workers.length == 1 ? '' : 's'} · offered in this order',
                      ),
                    ),
                  ),
                  if (workers.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Text(
                          'Go back and select at least one worker.',
                          style: TextStyle(
                            color: AppColors.mutedBrown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        return _WorkerConfirmRow(
                          worker: workers[index],
                          order: index + 1,
                          showDivider: index < workers.length - 1,
                        );
                      },
                    ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, 28),
                      child: _OfferNote(),
                    ),
                  ),
                ],
              );
            }),
          ),
          _BottomBar(controller: controller),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.workerCount,
    required this.category,
    required this.confidencePct,
  });

  final int workerCount;
  final String category;
  final double? confidencePct;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF6D8),
            AppColors.cream,
            AppColors.white,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, top + 4, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.nearBlack,
                ),
                const Expanded(
                  child: Text(
                    'Confirm job',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.nearBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review and\ncreate your job',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nearBlack,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Check the details below, then create to start offering.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedBrown.withValues(alpha: 0.98),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaTile(
                          label: 'Category',
                          value: category,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetaTile(
                          label: 'Workers',
                          value: '$workerCount selected',
                          emphasize: true,
                        ),
                      ),
                    ],
                  ),
                  if (confidencePct != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Match confidence ${confidencePct!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedBrown,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: emphasize
            ? AppColors.gold.withValues(alpha: 0.28)
            : AppColors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedBrown.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.nearBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.nearBlack,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedBrown.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }
}

class _ProblemSection extends StatelessWidget {
  const _ProblemSection({
    required this.controller,
    required this.editable,
  });

  final CreateJobController controller;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            title: editable ? 'Short description' : 'Problem',
            subtitle: editable
                ? 'Optional note for the worker (recommended)'
                : 'What you asked for help with',
          ),
          const SizedBox(height: 12),
          if (editable)
            TextField(
              controller: controller.problemController,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              onChanged: (value) => controller.problemText.value = value,
              decoration: InputDecoration(
                hintText: 'e.g. Kitchen sink is leaking',
                filled: true,
                fillColor: const Color(0xFFFFF8E7),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.mutedBrown.withValues(alpha: 0.16),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.mutedBrown.withValues(alpha: 0.16),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
                ),
              ),
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.nearBlack,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.mutedBrown.withValues(alpha: 0.16),
                ),
              ),
              child: Obx(() {
                final text = controller.problemText.value;
                return Text(
                  text.trim().isEmpty ? '—' : text.trim(),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.nearBlack,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.address});

  final SavedAddress? address;

  @override
  Widget build(BuildContext context) {
    final label = address == null
        ? 'No address'
        : (address!.label?.trim().isNotEmpty == true
            ? address!.label!.trim()
            : 'Saved address');
    final line = address == null
        ? 'Go back and choose a job address'
        : (address!.addressLine?.trim().isNotEmpty == true
            ? address!.addressLine!.trim()
            : 'No address line');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: _SectionLabel(
            title: 'Address',
            subtitle: 'Where the worker should arrive',
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.cream.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.mutedBrown.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.nearBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      line,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedBrown.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkerConfirmRow extends StatelessWidget {
  const _WorkerConfirmRow({
    required this.worker,
    required this.order,
    required this.showDivider,
  });

  final JobMatchWorker worker;
  final int order;
  final bool showDivider;

  static const _defaultAsset = 'assets/images/default_worker.png';

  @override
  Widget build(BuildContext context) {
    final name = worker.name?.trim().isNotEmpty == true
        ? worker.name!.trim()
        : 'Worker';
    final online = worker.isOnline == true;
    final hasNetwork =
        worker.profileImageUrl != null && worker.profileImageUrl!.trim().isNotEmpty;
    final distance = worker.distanceKm;
    final rating = worker.averageRating;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: AppColors.mutedBrown.withValues(alpha: 0.12),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: hasNetwork
                        ? CachedNetworkImage(
                            imageUrl: worker.profileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Image.asset(
                              _defaultAsset,
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (_, _, _) => Image.asset(
                              _defaultAsset,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(_defaultAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: online
                          ? const Color(0xFF2E7D32)
                          : AppColors.mutedBrown,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  left: -2,
                  top: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.nearBlack,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$order',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.nearBlack,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  [
                    if (rating != null) '★ ${rating.toStringAsFixed(1)}',
                    if (distance != null)
                      '${distance.toStringAsFixed(1)} km',
                    'Priority $order',
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferNote extends StatelessWidget {
  const _OfferNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'We offer this job to selected workers in order until one accepts.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppColors.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final CreateJobController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.mutedBrown.withValues(alpha: 0.14),
          ),
        ),
      ),
      child: Obx(
        () => PrimaryButton(
          label: 'Create job',
          isLoading: controller.isCreating.value,
          onPressed: controller.createJob,
        ),
      ),
    );
  }
}

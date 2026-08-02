import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../common_widgets/empty_state.dart';
import '../../../common_widgets/onee_loader.dart';
import '../../../common_widgets/primary_button.dart';
import '../../addresses/model/address_models.dart';
import '../model/job_models.dart';
import 'create_job_controller.dart';

class SelectWorkersView extends GetView<CreateJobController> {
  const SelectWorkersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final match = controller.matchResult.value;
              if (match == null) {
                return SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: Get.back,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const Expanded(
                        child: EmptyState(
                          message:
                              'No match result. Go back and describe again.',
                          icon: Icons.search_off_rounded,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final workers = match.workers;
              final selectedCount = controller.selectedWorkerIds.length;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeroHeader(
                      match: match,
                      selectedCount: selectedCount,
                      workerCount: workers.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _AddressSection(controller: controller),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: _SectionHeading(
                        title: 'Choose workers',
                        subtitle:
                            'Select one or more. Tap order is offer priority.',
                      ),
                    ),
                  ),
                  if (workers.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(
                          message:
                              'No workers matched this category nearby.\nTry describing the problem differently.',
                          icon: Icons.engineering_outlined,
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        final worker = workers[index];
                        return Obx(
                          () => _WorkerRow(
                            worker: worker,
                            selected: controller.isWorkerSelected(worker.id),
                            order: controller.workerOrder(worker.id),
                            onTap: () => controller.toggleWorker(worker.id),
                            showDivider: index < workers.length - 1,
                          ),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
    required this.match,
    required this.selectedCount,
    required this.workerCount,
  });

  final JobMatchResult match;
  final int selectedCount;
  final int workerCount;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final category =
        match.categoryName ?? match.predictedCategory ?? 'Matched category';
    final confidence = match.confidence;
    final pct = confidence == null
        ? null
        : (confidence <= 1 ? confidence * 100 : confidence);

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
                    'Select workers',
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
                    'We found matches\nfor your job',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nearBlack,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaPill(
                          label: 'Category',
                          value: category,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (pct != null)
                        _MetaPill(
                          label: 'Match',
                          value: '${pct.toStringAsFixed(0)}%',
                          emphasize: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedCount == 0
                        ? '$workerCount nearby · pick who to offer first'
                        : '$selectedCount selected · $workerCount nearby',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedBrown.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
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

class _AddressSection extends StatefulWidget {
  const _AddressSection({required this.controller});

  final CreateJobController controller;

  @override
  State<_AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<_AddressSection> {
  bool _expanded = false;

  CreateJobController get controller => widget.controller;

  void _toggle() => setState(() => _expanded = !_expanded);

  void _select(int id) {
    controller.selectAddress(id);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingAddresses.value && controller.addresses.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: OneeLoader(size: 28)),
        );
      }

      final list = controller.addresses;
      final selectedId = controller.selectedAddressId.value;
      SavedAddress? selected;
      for (final a in list) {
        if (a.id == selectedId) {
          selected = a;
          break;
        }
      }
      selected ??= list.isNotEmpty ? list.first : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: _SectionHeading(
              title: 'Job address',
              subtitle: 'Where should the worker come?',
            ),
          ),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: OutlinedButton.icon(
                onPressed: controller.goAddAddress,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add a saved address'),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.mutedBrown.withValues(alpha: 0.18),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _AddressAccordionHeader(
                    address: selected!,
                    expanded: _expanded,
                    onTap: _toggle,
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Column(
                      children: [
                        Divider(
                          height: 1,
                          color: AppColors.mutedBrown.withValues(alpha: 0.14),
                        ),
                        ...list.map((address) {
                          return _AddressChoiceRow(
                            address: address,
                            selected: address.id == selectedId,
                            onTap: () => _select(address.id),
                            compact: true,
                          );
                        }),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: controller.goAddAddress,
                            child: const Text(
                              'Add new address',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                    sizeCurve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

class _AddressAccordionHeader extends StatelessWidget {
  const _AddressAccordionHeader({
    required this.address,
    required this.expanded,
    required this.onTap,
  });

  final SavedAddress address;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = (address.label != null && address.label!.trim().isNotEmpty)
        ? address.label!.trim()
        : 'Address #${address.id}';
    final line =
        (address.addressLine != null && address.addressLine!.trim().isNotEmpty)
            ? address.addressLine!.trim()
            : 'No address line';

    return Material(
      color: AppColors.cream.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.gold,
                  size: 22,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedBrown.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                expanded ? 'Close' : 'Change',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 2),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressChoiceRow extends StatelessWidget {
  const _AddressChoiceRow({
    required this.address,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final SavedAddress address;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = (address.label != null && address.label!.trim().isNotEmpty)
        ? address.label!.trim()
        : 'Address #${address.id}';
    final line =
        (address.addressLine != null && address.addressLine!.trim().isNotEmpty)
            ? address.addressLine!.trim()
            : 'No address line';

    return Material(
      color: selected
          ? AppColors.cream.withValues(alpha: 0.45)
          : AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 14 : 24,
            12,
            compact ? 14 : 20,
            12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.mutedBrown.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: selected ? AppColors.gold : AppColors.mutedBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.nearBlack,
                            ),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedBrown.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppColors.gold : AppColors.mutedBrown,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerRow extends StatelessWidget {
  const _WorkerRow({
    required this.worker,
    required this.selected,
    required this.order,
    required this.onTap,
    required this.showDivider,
  });

  final JobMatchWorker worker;
  final bool selected;
  final int order;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final name = (worker.name != null && worker.name!.trim().isNotEmpty)
        ? worker.name!.trim()
        : 'Worker';
    final rating = worker.averageRating;
    final distance = worker.distanceKm;
    final online = worker.isOnline == true;

    return Material(
      color: selected
          ? AppColors.cream.withValues(alpha: 0.4)
          : AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
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
              _WorkerAvatar(
                url: worker.profileImageUrl,
                selected: selected,
                order: order,
                online: online,
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
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (rating != null)
                          _StatChip(
                            icon: Icons.star_rounded,
                            text:
                                '${rating.toStringAsFixed(1)}'
                                '${worker.ratingCount != null ? ' (${worker.ratingCount})' : ''}',
                          ),
                        if (distance != null)
                          _StatChip(
                            icon: Icons.near_me_rounded,
                            text: '${distance.toStringAsFixed(1)} km',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected ? AppColors.gold : AppColors.mutedBrown,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedBrown),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedBrown,
          ),
        ),
      ],
    );
  }
}

class _WorkerAvatar extends StatelessWidget {
  const _WorkerAvatar({
    required this.url,
    required this.selected,
    required this.order,
    required this.online,
  });

  final String? url;
  final bool selected;
  final int order;
  final bool online;

  static const _defaultAsset = 'assets/images/default_worker.png';

  @override
  Widget build(BuildContext context) {
    final hasNetwork = url != null && url!.trim().isNotEmpty;

    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.gold
                    : AppColors.mutedBrown.withValues(alpha: 0.2),
                width: selected ? 2.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.nearBlack.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: hasNetwork
                  ? CachedNetworkImage(
                      imageUrl: url!,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      placeholder: (_, _) => Image.asset(
                        _defaultAsset,
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (_, _, _) => Image.asset(
                        _defaultAsset,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      _defaultAsset,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                    ),
            ),
          ),
          // Online / offline status over the image
          Positioned(
            right: 2,
            bottom: 2,
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
          if (selected)
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
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final CreateJobController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.selectedWorkerIds.length;
      final hasAddress = controller.selectedAddressId.value != null;
      final canContinue = count > 0 && hasAddress;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  count == 1
                      ? '1 worker selected'
                      : '$count workers selected · offer order set',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedBrown,
                  ),
                ),
              ),
            PrimaryButton(
              label: 'Continue',
              enabled: canContinue,
              onPressed: controller.goConfirm,
            ),
          ],
        ),
      );
    });
  }
}

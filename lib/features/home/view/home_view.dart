import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../common_widgets/empty_state.dart';
import '../../../common_widgets/job_status_chip.dart';
import '../../../common_widgets/onee_loader.dart';
import '../../addresses/model/address_models.dart';
import '../../jobs/model/job_models.dart';
import '../controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: OneeLoader());
        }

        return RefreshIndicator(
          color: AppColors.gold,
          displacement: 48,
          onRefresh: controller.refreshAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroHeader(
                      name: controller.user.value?.name,
                      onCreateJob: controller.goCreateJob,
                    ),
                    _FadeSlide(
                      delayMs: 80,
                      child: Obx(
                        () => _AddressBar(
                          address: controller.selectedAddress.value,
                          onChange: controller.goAddresses,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _SectionTitle(
                        title: 'Active jobs',
                        subtitle: 'Jobs still in progress',
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _RecentJobsSliver(controller: controller),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      }),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.name,
    required this.onCreateJob,
  });

  final String? name;
  final VoidCallback onCreateJob;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final display = _firstName(name);

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
        padding: EdgeInsets.fromLTRB(24, top + 16, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FadeSlide(
              child: Image.asset(
                'assets/images/logo_splash.png',
                height: 40,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 28),
            _FadeSlide(
              delayMs: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $display',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nearBlack,
                      height: 1.1,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Book a trusted worker in minutes.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: AppColors.mutedBrown,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _FadeSlide(
              delayMs: 100,
              child: _CreateJobCta(onPressed: onCreateJob),
            ),
          ],
        ),
      ),
    );
  }

  static String _firstName(String? name) {
    if (name == null || name.trim().isEmpty) return 'there';
    return name.trim().split(RegExp(r'\s+')).first;
  }
}

class _CreateJobCta extends StatefulWidget {
  const _CreateJobCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_CreateJobCta> createState() => _CreateJobCtaState();
}

class _CreateJobCtaState extends State<_CreateJobCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.nearBlack,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.nearBlack,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a job',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Describe a problem or browse categories',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.gold,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressBar extends StatelessWidget {
  const _AddressBar({
    required this.address,
    required this.onChange,
  });

  final SavedAddress? address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null;
    final label = hasAddress &&
            address!.label != null &&
            address!.label!.trim().isNotEmpty
        ? address!.label!.trim()
        : (hasAddress ? 'Saved address' : 'No address');
    final line = hasAddress &&
            address!.addressLine != null &&
            address!.addressLine!.trim().isNotEmpty
        ? address!.addressLine!.trim()
        : (hasAddress
            ? 'Tap Change to update details'
            : 'Add a delivery address to get started');

    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onChange,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.mutedBrown.withValues(alpha: 0.16),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.9),
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
              const SizedBox(width: 10),
              Text(
                hasAddress ? 'Change' : 'Add',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.nearBlack,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedBrown.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }
}

class _RecentJobsSliver extends StatelessWidget {
  const _RecentJobsSliver({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.jobsError.value;
      final jobs = controller.recentJobs;

      if (error != null && jobs.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(
            message: error,
            onRetry: controller.loadRecentJobs,
          ),
        );
      }

      if (jobs.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: EmptyState(
              message:
                  'No active jobs yet.\nDescribe a problem to get started.',
              icon: Icons.handyman_outlined,
            ),
          ),
        );
      }

      return SliverList.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _FadeSlide(
            delayMs: 60 + (index * 40),
            child: _JobRow(
              job: job,
              onTap: () => controller.openJob(job.id),
              showDivider: index < jobs.length - 1,
            ),
          );
        },
      );
    });
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({
    required this.job,
    required this.onTap,
    required this.showDivider,
  });

  final JobListItem job;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final title =
        (job.problemText != null && job.problemText!.trim().isNotEmpty)
            ? job.problemText!.trim()
            : (job.categoryName ?? 'Job #${job.id}');

    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.nearBlack,
                        height: 1.3,
                      ),
                    ),
                    if (job.workerName != null &&
                        job.workerName!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        job.workerName!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    JobStatusChip(status: job.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedBrown.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({
    required this.child,
    this.delayMs = 0,
  });

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final t = Curves.easeOut.transform(value.clamp(0.0, 1.0));
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

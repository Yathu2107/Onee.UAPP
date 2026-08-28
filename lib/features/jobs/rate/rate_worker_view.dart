import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../common_widgets/profile_image_avatar.dart';
import 'rate_worker_controller.dart';

class RateWorkerView extends GetView<RateWorkerController> {
  const RateWorkerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(child: _RateHero()),
                Obx(
                  () => SliverToBoxAdapter(
                    child: _WorkerBlock(
                      name: controller.workerName.value,
                      imageUrl: controller.workerImageUrl.value,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                    child: Column(
                      children: [
                        Obx(() {
                          final value = controller.rating.value;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  final star = index + 1;
                                  final filled = star <= value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: _StarButton(
                                      filled: filled,
                                      onTap: () => controller.setRating(star),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Text(
                                  controller.ratingLabel,
                                  key: ValueKey(controller.ratingLabel),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: value == 0
                                        ? AppColors.mutedBrown
                                        : AppColors.nearBlack,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 28),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Quick feedback',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.nearBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(() {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tag in RateWorkerController.quickTags)
                                _QuickTag(
                                  label: tag,
                                  selected:
                                      controller.selectedQuickTags.contains(tag),
                                  onTap: () => controller.toggleTag(tag),
                                ),
                            ],
                          );
                        }),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tell us more',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.nearBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Optional — what went well or what could improve?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mutedBrown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: controller.feedbackController,
                          minLines: 4,
                          maxLines: 7,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.nearBlack,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write your feedback here…',
                            filled: true,
                            fillColor: const Color(0xFFFFF8E7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: AppColors.mutedBrown.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: AppColors.mutedBrown.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: AppColors.gold,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BottomBar(controller: controller),
        ],
      ),
    );
  }
}

class _RateHero extends StatelessWidget {
  const _RateHero();

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
        padding: EdgeInsets.fromLTRB(8, top + 4, 16, 12),
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
                    'Rate & feedback',
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How was the\nservice?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nearBlack,
                      height: 1.12,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your rating helps other customers pick great workers.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedBrown,
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

class _WorkerBlock extends StatelessWidget {
  const _WorkerBlock({
    required this.name,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.mutedBrown.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            ProfileImageAvatar(
              imageUrl: imageUrl,
              size: 52,
              borderColor: AppColors.gold.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating for',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedBrown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nearBlack,
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

class _StarButton extends StatefulWidget {
  const _StarButton({
    required this.filled,
    required this.onTap,
  });

  final bool filled;
  final VoidCallback onTap;

  @override
  State<_StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<_StarButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedScale(
          scale: widget.filled ? 1.08 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: Icon(
            widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 44,
            color: widget.filled ? AppColors.gold : AppColors.mutedBrown,
          ),
        ),
      ),
    );
  }
}

class _QuickTag extends StatelessWidget {
  const _QuickTag({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.gold.withValues(alpha: 0.35)
          : AppColors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : AppColors.mutedBrown.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.nearBlack : AppColors.mutedBrown,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final RateWorkerController controller;

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
          label: 'Submit rating',
          isLoading: controller.isSubmitting.value,
          enabled: controller.rating.value > 0,
          onPressed: controller.submit,
        ),
      ),
    );
  }
}

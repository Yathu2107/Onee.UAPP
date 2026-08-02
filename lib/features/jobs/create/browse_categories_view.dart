import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../common_widgets/empty_state.dart';
import '../../../common_widgets/onee_loader.dart';
import '../model/job_models.dart';
import 'create_job_controller.dart';

class BrowseCategoriesView extends StatefulWidget {
  const BrowseCategoriesView({super.key});

  @override
  State<BrowseCategoriesView> createState() => _BrowseCategoriesViewState();
}

class _BrowseCategoriesViewState extends State<BrowseCategoriesView> {
  late final CreateJobController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CreateJobController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
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
                          'Categories',
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
                          'Browse by\ncategory',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.nearBlack,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Choose a service type to see nearby workers.',
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
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCategories.value &&
                  controller.categories.isEmpty) {
                return const Center(child: OneeLoader());
              }

              final err = controller.categoriesError.value;
              if (err != null && controller.categories.isEmpty) {
                return ErrorState(
                  message: err,
                  onRetry: controller.loadCategories,
                );
              }

              final items = controller.categories.toList();
              if (items.isEmpty) {
                return const EmptyState(
                  message: 'No categories available.',
                  icon: Icons.category_outlined,
                );
              }

              return Stack(
                children: [
                  RefreshIndicator(
                    color: AppColors.gold,
                    onRefresh: controller.loadCategories,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _CategoryTile(
                          category: item,
                          enabled: !controller.isFinding.value,
                          onTap: () =>
                              controller.findWorkersByCategory(item),
                        );
                      },
                    ),
                  ),
                  if (controller.isFinding.value)
                    const ColoredBox(
                      color: Color(0x66FFFFFF),
                      child: Center(child: OneeLoader()),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.enabled,
  });

  final JobCategory category;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
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
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.9),
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
                child: Text(
                  category.categoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.nearBlack,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedBrown.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';

/// Entry screen: describe with AI vs browse categories.
class CreateJobChooserView extends StatelessWidget {
  const CreateJobChooserView({super.key});

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
                          'Create job',
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
                          'How do you want\nto book?',
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
                          'Describe the problem with AI, or pick a category.',
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              physics: const BouncingScrollPhysics(),
              children: [
                _PathCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Describe your problem',
                  subtitle:
                      'Tell us what’s wrong — AI finds matching nearby workers.',
                  onTap: () => Get.toNamed(AppRoutes.createJobDescribe),
                ),
                const SizedBox(height: 14),
                _PathCard(
                  icon: Icons.grid_view_rounded,
                  title: 'Browse categories',
                  subtitle:
                      'Pick Plumbing, Electrical, and more, then choose workers.',
                  onTap: () => Get.toNamed(AppRoutes.createJobCategories),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.mutedBrown.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.gold, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.nearBlack,
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

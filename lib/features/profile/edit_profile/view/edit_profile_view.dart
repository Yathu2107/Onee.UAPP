import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../common_widgets/onee_loader.dart';
import '../controller/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: OneeLoader());
        }

        return Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _EditProfileHero(
                        onBack: () => Get.back(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _ProfilePhotoPicker(),
                            const SizedBox(height: 28),
                            const _FieldLabel('Full name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.nameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              validator: controller.validateName,
                              style: _fieldStyle,
                              decoration: _inputDecoration(
                                hint: 'Your name',
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel('Email'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: controller.validateEmail,
                              style: _fieldStyle,
                              decoration: _inputDecoration(
                                hint: 'you@email.com',
                                icon: Icons.mail_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel('Mobile number'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: controller.validatePhone,
                              style: _fieldStyle.copyWith(letterSpacing: 1.1),
                              decoration: _inputDecoration(
                                hint: '07XXXXXXXX',
                                icon: Icons.smartphone_rounded,
                              ).copyWith(counterText: ''),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _SaveBar(
                isLoading: controller.isSaving.value,
                onPressed: controller.submit,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _EditProfileHero extends StatelessWidget {
  const _EditProfileHero({required this.onBack});

  final VoidCallback onBack;

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
        padding: EdgeInsets.fromLTRB(16, top + 8, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.nearBlack,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit profile',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nearBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Keep your photo and contact details current',
                    style: TextStyle(
                      fontSize: 14,
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

class _SaveBar extends StatefulWidget {
  const _SaveBar({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<_SaveBar> createState() => _SaveBarState();
}

class _SaveBarState extends State<_SaveBar> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final canTap = !widget.isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.mutedBrown.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: GestureDetector(
        onTapDown: canTap ? (_) => setState(() => _pressed = true) : null,
        onTapUp: canTap ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: canTap ? () => setState(() => _pressed = false) : null,
        onTap: canTap ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.nearBlack,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: OneeLoader(size: 22),
                  )
                : const Text(
                    'Save changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

const _fieldStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.nearBlack,
);

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.nearBlack,
        letterSpacing: 0.2,
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.cream.withValues(alpha: 0.28),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    prefixIcon: Icon(icon, color: AppColors.mutedBrown),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: AppColors.mutedBrown.withValues(alpha: 0.28),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: AppColors.mutedBrown.withValues(alpha: 0.28),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.gold, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFB3261E)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.6),
    ),
  );
}

class _ProfilePhotoPicker extends GetView<EditProfileController> {
  const _ProfilePhotoPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final path = controller.imagePath.value;
      final networkUrl = controller.existingImageUrl.value;
      final hasLocal = path != null && path.isNotEmpty;
      final hasNetwork =
          !hasLocal && networkUrl != null && networkUrl.isNotEmpty;

      return Column(
        children: [
          GestureDetector(
            onTap: controller.pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cream.withValues(alpha: 0.9),
                    border: Border.all(color: AppColors.gold, width: 2.5),
                    image: hasLocal
                        ? DecorationImage(
                            image: FileImage(File(path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasLocal
                      ? null
                      : hasNetwork
                          ? CachedNetworkImage(
                              imageUrl: networkUrl,
                              fit: BoxFit.cover,
                              width: 112,
                              height: 112,
                              placeholder: (context, url) =>
                                  const Center(child: OneeLoader(size: 24)),
                              errorWidget: (context, url, error) =>
                                  const _PhotoPlaceholder(),
                            )
                          : const _PhotoPlaceholder(),
                ),
                if (hasLocal || hasNetwork)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Material(
                      color: AppColors.nearBlack,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: controller.clearImage,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: AppColors.nearBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            (hasLocal || hasNetwork)
                ? 'Tap to change photo'
                : 'Optional profile photo',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedBrown.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    });
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 28,
          color: AppColors.mutedBrown,
        ),
        SizedBox(height: 6),
        Text(
          'Add photo',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedBrown,
          ),
        ),
      ],
    );
  }
}

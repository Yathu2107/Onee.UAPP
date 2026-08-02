import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../common_widgets/primary_button.dart';
import 'complaint_controller.dart';

class ComplaintView extends GetView<ComplaintController> {
  const ComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Create complaint')),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tell us what went wrong',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.nearBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Job #${controller.jobId}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.nearBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.subjectController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        validator: controller.validateSubject,
                        decoration: const InputDecoration(
                          hintText: 'Short summary',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.nearBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.descriptionController,
                        minLines: 5,
                        maxLines: 8,
                        textCapitalization: TextCapitalization.sentences,
                        validator: controller.validateDescription,
                        decoration: const InputDecoration(
                          hintText: 'Describe the issue in detail…',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Obx(
                  () => PrimaryButton(
                    label: 'Submit complaint',
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.submit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../common_widgets/primary_button.dart';
import 'create_job_controller.dart';

class DescribeJobView extends GetView<CreateJobController> {
  const DescribeJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _DescribeHero(controller: controller),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: Obx(() {
                        final listening = controller.isListening.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ProblemField(
                              controller: controller,
                              listening: listening,
                            ),
                            const SizedBox(height: 20),
                            _VoicePanel(controller: controller),
                            const SizedBox(height: 20),
                            const _Tips(),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            _BottomBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _DescribeHero extends StatelessWidget {
  const _DescribeHero({required this.controller});

  final CreateJobController controller;

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
                    'Describe problem',
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
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What do you need\nhelp with?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.nearBlack,
                      height: 1.15,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Type it out or tap the mic and speak — we match nearby workers from your description.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.mutedBrown.withValues(alpha: 0.98),
                      fontWeight: FontWeight.w500,
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

class _ProblemField extends StatelessWidget {
  const _ProblemField({
    required this.controller,
    required this.listening,
  });

  final CreateJobController controller;
  final bool listening;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: listening
              ? AppColors.gold
              : AppColors.mutedBrown.withValues(alpha: 0.22),
          width: listening ? 1.8 : 1,
        ),
        color: listening
            ? AppColors.cream.withValues(alpha: 0.35)
            : const Color(0xFFFFF8E7),
      ),
      child: TextFormField(
        controller: controller.problemController,
        minLines: 6,
        maxLines: 12,
        textCapitalization: TextCapitalization.sentences,
        validator: controller.validateProblem,
        style: const TextStyle(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: AppColors.nearBlack,
        ),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          hintText: listening
              ? 'Listening… speak clearly'
              : 'e.g. Kitchen sink is leaking and water is pooling on the floor…',
          hintStyle: TextStyle(
            color: AppColors.mutedBrown.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _VoicePanel extends StatelessWidget {
  const _VoicePanel({required this.controller});

  final CreateJobController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final listening = controller.isListening.value;
      final available = controller.speechAvailable.value;

      return Column(
        children: [
          Center(
            child: _VoiceButton(
              listening: listening,
              enabled: available || listening,
              onPressed: controller.toggleVoiceInput,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            listening
                ? 'Listening — tap again to stop'
                : available
                    ? 'Tap to speak your problem'
                    : 'Voice input unavailable on this device',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: listening ? AppColors.gold : AppColors.mutedBrown,
            ),
          ),
        ],
      );
    });
  }
}

class _VoiceButton extends StatefulWidget {
  const _VoiceButton({
    required this.listening,
    required this.enabled,
    required this.onPressed,
  });

  final bool listening;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<_VoiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.listening) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listening && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.listening && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale = widget.listening ? 1 + (_pulse.value * 0.08) : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: widget.listening ? AppColors.nearBlack : AppColors.gold,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.enabled ? widget.onPressed : null,
          child: SizedBox(
            width: 76,
            height: 76,
            child: Icon(
              widget.listening ? Icons.stop_rounded : Icons.mic_rounded,
              size: 34,
              color: widget.listening ? AppColors.gold : AppColors.nearBlack,
            ),
          ),
        ),
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Helpful tips',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.nearBlack,
          ),
        ),
        const SizedBox(height: 10),
        _tip('Say what broke and where it is'),
        _tip('Mention urgency if you need help today'),
        _tip('You can edit the text after speaking'),
      ],
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedBrown.withValues(alpha: 0.95),
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
          label: 'Find workers',
          isLoading: controller.isFinding.value,
          onPressed: controller.findWorkers,
        ),
      ),
    );
  }
}

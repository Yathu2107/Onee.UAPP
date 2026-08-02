import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../model/job_models.dart';
import 'job_detail_controller.dart';

/// Uber / PickMe style “requesting a worker” experience while status is Offering.
class JobRequestingView extends StatefulWidget {
  const JobRequestingView({
    super.key,
    required this.controller,
    required this.job,
  });

  final JobDetailController controller;
  final JobDetail job;

  @override
  State<JobRequestingView> createState() => _JobRequestingViewState();
}

class _JobRequestingViewState extends State<JobRequestingView>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _orbit;
  late final AnimationController _messageCycle;

  static const _messages = [
    'Looking for nearby workers…',
    'Sending your request…',
    'Waiting for someone to accept…',
    'Hang tight — help is on the way…',
  ];

  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _messageCycle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _messageIndex = (_messageIndex + 1) % _messages.length;
          });
          _messageCycle
            ..reset()
            ..forward();
        }
      });
    _messageCycle.forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _orbit.dispose();
    _messageCycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final problem = job.problemText?.trim().isNotEmpty == true
        ? job.problemText!.trim()
        : 'Your job request';
    final category = job.categoryName?.trim().isNotEmpty == true
        ? job.categoryName!.trim()
        : 'Matching workers';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF6D8),
              AppColors.cream,
              AppColors.white,
              AppColors.white,
            ],
            stops: [0.0, 0.28, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.nearBlack,
                    ),
                    const Expanded(
                      child: Text(
                        'Requesting',
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
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_pulse, _orbit]),
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _RadarPainter(
                                  pulse: _pulse.value,
                                  orbit: _orbit.value,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: AppColors.nearBlack,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gold.withValues(
                                            alpha: 0.45,
                                          ),
                                          blurRadius: 24,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.handyman_rounded,
                                      color: AppColors.gold,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _messages[_messageIndex],
                        key: ValueKey(_messageIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.nearBlack,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final countdown =
                          widget.controller.offerCountdown.value;
                      return Text(
                        countdown == null
                            ? 'Finding the best match for you'
                            : countdown == 'Expired'
                                ? 'Offer expired — updating…'
                                : 'Offer expires in $countdown',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedBrown,
                        ),
                      );
                    }),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.mutedBrown.withValues(alpha: 0.16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.nearBlack.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.nearBlack,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '#${job.id}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mutedBrown,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              problem,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                color: AppColors.nearBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SearchingDots(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'We’ll notify you as soon as a worker accepts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedBrown.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => OutlinedButton(
                        onPressed: widget.controller.isCancelling.value
                            ? null
                            : () => widget.controller.cancelJob(
                                  goHomeAfter: true,
                                ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB3261E),
                          side: const BorderSide(color: Color(0xFFB3261E)),
                        ),
                        child: widget.controller.isCancelling.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFB3261E),
                                ),
                              )
                            : const Text('Cancel request'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchingDots extends StatefulWidget {
  const _SearchingDots();

  @override
  State<_SearchingDots> createState() => _SearchingDotsState();
}

class _SearchingDotsState extends State<_SearchingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = (_controller.value + i * 0.2) % 1.0;
            final scale = 0.65 + (math.sin(t * math.pi) * 0.45);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.pulse, required this.orbit});

  final double pulse;
  final double orbit;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.48;

    for (var i = 0; i < 3; i++) {
      final progress = (pulse + i / 3) % 1.0;
      final radius = 40 + progress * (maxR - 40);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.gold.withValues(alpha: 0.55 * opacity);
      canvas.drawCircle(center, radius, paint);
    }

    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.mutedBrown.withValues(alpha: 0.18);
    canvas.drawCircle(center, maxR * 0.55, soft);
    canvas.drawCircle(center, maxR * 0.78, soft);

    final angle = orbit * 2 * math.pi;
    final orbitR = maxR * 0.72;
    final dot = Offset(
      center.dx + orbitR * math.cos(angle),
      center.dy + orbitR * math.sin(angle),
    );
    canvas.drawCircle(
      dot,
      6,
      Paint()..color = AppColors.nearBlack,
    );
    canvas.drawCircle(
      Offset(
        center.dx + orbitR * math.cos(angle + 2.1),
        center.dy + orbitR * math.sin(angle + 2.1),
      ),
      4.5,
      Paint()..color = AppColors.gold,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.orbit != orbit;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../models/walkthrough_step.dart';
import '../services/walkthrough_voice_service.dart';

/// Premium, responsive tooltip card presenting feature explanations, tips,
/// interactive demos, voice controls, and navigation buttons.
/// Matches the official reference design with:
/// - Rounded corners (18px)
/// - Voice status pill: "• 🔊 Voice: Speaking..." or "✓ Voice: Finished"
/// - Close (X) icon at top-right
/// - Clean typography for title & description
/// - Mint & emerald green Deep-Dive CTA Card with question prompt
/// - Step indicator (e.g. 18 of 27)
/// - Back and Next/Finish action buttons
/// - Triangular pointer arrow pointing to the spotlight cutout
class WalkthroughTooltip extends StatelessWidget {
  const WalkthroughTooltip({
    super.key,
    required this.step,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.onClose,
    required this.onSkip,
    this.onExploreInDepth,
    this.onRunDemo,
    this.pointerDirection = TooltipPointerDirection.none,
    this.pointerHorizontalOffset = 0.5,
  });

  final WalkthroughStep step;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onSkip;
  final VoidCallback? onExploreInDepth;
  final VoidCallback? onRunDemo;
  final TooltipPointerDirection pointerDirection;
  final double pointerHorizontalOffset;

  bool get isLastStep => currentStepIndex >= totalSteps - 1;
  bool get canGoBack => currentStepIndex > 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    final cardWidth = isMobile
        ? (size.width - 24.0).clamp(320.0, 480.0)
        : (size.width * 0.48).clamp(400.0, 540.0);
    final padding = MediaQuery.paddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final safeHeight = size.height - padding.top - padding.bottom - viewInsets.bottom;
    final maxCardHeight = (safeHeight * 0.70).clamp(320.0, 560.0);

    final voiceService = Get.isRegistered<WalkthroughVoiceService>()
        ? Get.find<WalkthroughVoiceService>()
        : null;

    final isArrowUp = pointerDirection == TooltipPointerDirection.top;
    final isArrowDown = pointerDirection == TooltipPointerDirection.bottom;
    final showArrow = step.showArrow && (isArrowUp || isArrowDown);

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pointer Arrow (Pointing UP towards spotlight)
            if (showArrow && isArrowUp)
              CustomPaint(
                size: const Size(double.infinity, 10),
                painter: _PointerArrowPainter(
                  direction: TooltipPointerDirection.top,
                  offsetRatio: pointerHorizontalOffset,
                  color: Colors.white,
                  borderColor: const Color(0xFFE2E8F0),
                ),
              ),

            // Main Tooltip White Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              constraints: BoxConstraints(
                maxHeight: maxCardHeight,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Header: Voice Pill & Close Button ────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Voice Status Badge (Tapping toggles voice)
                        if (voiceService != null)
                          Obx(() {
                            final isSpeaking = voiceService.isSpeaking.value;
                            final isEnabled = voiceService.isVoiceEnabled.value;
                            return _VoiceBadge(
                              isSpeaking: isSpeaking,
                              isEnabled: isEnabled,
                              customBadgeText: step.badgeText,
                              onTap: () => voiceService.toggleVoice(),
                            );
                          })
                        else
                          _VoiceBadge(
                            isSpeaking: false,
                            isEnabled: true,
                            customBadgeText: step.badgeText,
                            onTap: () {},
                          ),

                        // Close (X) Icon Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onClose,
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Body: Category, Title, Description, Deep Dive & Tips ──
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: step.category.color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: step.category.color.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(step.category.icon, size: 12, color: step.category.color),
                              const SizedBox(width: 4),
                              Text(
                                step.category.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: step.category.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Description
                        Text(
                          step.description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF475569),
                          ),
                        ),

                        // Tips Callout
                        if (step.tips != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded,
                                    size: 15, color: Color(0xFF16A34A)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    step.tips!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Action Instruction Prompt
                        if (step.actionInstruction != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.touch_app_outlined,
                                    size: 15, color: Color(0xFF2563EB)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    step.actionInstruction!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ─── Emerald Green Deep Dive CTA Card ───────────────
                        if (step.hasDeepDive && onExploreInDepth != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  step.deepDivePrompt ??
                                      'Want a complete interactive walkthrough of this module and its workflows?',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Material(
                                  color: const Color(0xFF0D9488),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: onExploreInDepth,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.search_rounded,
                                              size: 16, color: Colors.white),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              step.resolvedExploreButtonLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Interactive Demo Button
                        if (step.interactiveDemo != null && onRunDemo != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: onRunDemo,
                              icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                              label: const Text(
                                'Try Live Interactive Demo',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

                  // ─── Footer: Step Indicator, Back, Next/Finish, Skip ───────
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Step Counter Indicator (e.g. "18 of 27")
                        Text(
                          '${currentStepIndex + 1} of $totalSteps',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Skip link
                        InkWell(
                          onTap: onSkip,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              'Skip Tour',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Back Button
                        if (canGoBack) ...[
                          Material(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                            ),
                            child: InkWell(
                              onTap: onBack,
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Next / Finish Button
                        Material(
                          color: const Color(0xFF1E5BD8),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: onNext,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              child: Text(
                                isLastStep ? 'Finish' : 'Next',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pointer Arrow (Pointing DOWN towards spotlight)
            if (showArrow && isArrowDown)
              CustomPaint(
                size: const Size(double.infinity, 10),
                painter: _PointerArrowPainter(
                  direction: TooltipPointerDirection.bottom,
                  offsetRatio: pointerHorizontalOffset,
                  color: Colors.white,
                  borderColor: const Color(0xFFE2E8F0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Voice Guidance status pill badge with click-to-toggle support.
class _VoiceBadge extends StatelessWidget {
  const _VoiceBadge({
    required this.isSpeaking,
    required this.isEnabled,
    required this.onTap,
    this.customBadgeText,
  });

  final bool isSpeaking;
  final bool isEnabled;
  final VoidCallback onTap;
  final String? customBadgeText;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String label;

    if (!isEnabled) {
      bg = const Color(0xFFF1F5F9);
      border = const Color(0xFFE2E8F0);
      text = const Color(0xFF64748B);
      icon = Icons.volume_off_rounded;
      label = 'Voice: Muted';
    } else if (isSpeaking) {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFFBFDBFE);
      text = const Color(0xFF2563EB);
      icon = Icons.volume_up_rounded;
      label = customBadgeText ?? 'Voice: Speaking...';
    } else {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFFA7F3D0);
      text = const Color(0xFF059669);
      icon = Icons.check_rounded;
      label = customBadgeText ?? 'Voice: Finished';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: text),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TooltipPointerDirection {
  none,
  top,
  bottom,
  left,
  right,
}

/// Triangular pointer arrow painter.
class _PointerArrowPainter extends CustomPainter {
  const _PointerArrowPainter({
    required this.direction,
    required this.offsetRatio,
    required this.color,
    required this.borderColor,
  });

  final TooltipPointerDirection direction;
  final double offsetRatio;
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (direction == TooltipPointerDirection.none) return;

    const arrowWidth = 16.0;
    final arrowHeight = size.height;
    final centerX = (size.width * offsetRatio).clamp(arrowWidth, size.width - arrowWidth);

    final path = Path();
    final borderPath = Path();

    if (direction == TooltipPointerDirection.top) {
      // Tip points UP
      path.moveTo(centerX - (arrowWidth / 2), arrowHeight);
      path.lineTo(centerX, 0);
      path.lineTo(centerX + (arrowWidth / 2), arrowHeight);
      path.close();

      borderPath.moveTo(centerX - (arrowWidth / 2), arrowHeight);
      borderPath.lineTo(centerX, 0);
      borderPath.lineTo(centerX + (arrowWidth / 2), arrowHeight);
    } else {
      // Tip points DOWN
      path.moveTo(centerX - (arrowWidth / 2), 0);
      path.lineTo(centerX, arrowHeight);
      path.lineTo(centerX + (arrowWidth / 2), 0);
      path.close();

      borderPath.moveTo(centerX - (arrowWidth / 2), 0);
      borderPath.lineTo(centerX, arrowHeight);
      borderPath.lineTo(centerX + (arrowWidth / 2), 0);
    }

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(
      borderPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _PointerArrowPainter oldDelegate) {
    return oldDelegate.offsetRatio != offsetRatio ||
        oldDelegate.direction != direction ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}

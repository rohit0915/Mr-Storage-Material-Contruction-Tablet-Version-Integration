import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../models/walkthrough_step.dart';
import 'walkthrough_tooltip.dart';

/// Overlay widget that renders the dark backdrop with a spotlight cutout,
/// glowing highlight ring, and dynamically positioned tooltip card.
class WalkthroughOverlay extends StatefulWidget {
  const WalkthroughOverlay({
    super.key,
    required this.step,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.targetRect,
    required this.onBack,
    required this.onNext,
    required this.onClose,
    required this.onSkip,
    this.onExploreInDepth,
    this.onRunDemo,
  });

  final WalkthroughStep step;
  final int currentStepIndex;
  final int totalSteps;
  final Rect? targetRect;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onSkip;
  final VoidCallback? onExploreInDepth;
  final VoidCallback? onRunDemo;

  @override
  State<WalkthroughOverlay> createState() => _WalkthroughOverlayState();
}

class _WalkthroughOverlayState extends State<WalkthroughOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  Rect? _currentRect;
  Rect? _previousRect;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);

    _currentRect = widget.targetRect;
    _animController.forward();
  }

  @override
  void didUpdateWidget(WalkthroughOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetRect != widget.targetRect ||
        oldWidget.currentStepIndex != widget.currentStepIndex) {
      _previousRect = _currentRect;
      _currentRect = widget.targetRect;
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        // Interpolate target rect during step transition for smooth spotlight morphing
        final activeRect = Rect.lerp(_previousRect, _currentRect, _fadeAnim.value) ?? _currentRect;

        final paddedRect = activeRect != null
            ? Rect.fromLTRB(
                activeRect.left - widget.step.spotlightPadding.left,
                activeRect.top - widget.step.spotlightPadding.top,
                activeRect.right + widget.step.spotlightPadding.right,
                activeRect.bottom + widget.step.spotlightPadding.bottom,
              )
            : null;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ─── Spotlight Dark Backdrop ───────────────────────────────────
            CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(
                targetRect: paddedRect,
                spotlightRadius: widget.step.spotlightRadius,
                overlayColor: Colors.black.withValues(alpha: 0.72),
                glowColor: AppColors.primaryBlue.withValues(alpha: 0.8),
                animValue: _fadeAnim.value,
              ),
            ),

            // ─── Click Absorb / Background Dismiss Listener ────────────────
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // Clicking outside does not advance accidentally to avoid mis-clicks
              },
            ),

            // ─── Positioned Tooltip Card ───────────────────────────────────
            _buildPositionedTooltip(screenSize, paddedRect),
          ],
        );
      },
    );
  }

  Widget _buildPositionedTooltip(Size screenSize, Rect? targetRect) {
    // If no target, center on screen as welcome or summary modal
    if (targetRect == null || targetRect.isEmpty) {
      return Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: WalkthroughTooltip(
            step: widget.step,
            currentStepIndex: widget.currentStepIndex,
            totalSteps: widget.totalSteps,
            onBack: widget.onBack,
            onNext: widget.onNext,
            onClose: widget.onClose,
            onSkip: widget.onSkip,
            onExploreInDepth: widget.onExploreInDepth,
            onRunDemo: widget.onRunDemo,
            pointerDirection: TooltipPointerDirection.none,
          ),
        ),
      );
    }

    final mediaQuery = MediaQuery.of(context);
    final safePadding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;

    final isMobile = screenSize.width < 600;
    final cardWidth = isMobile
        ? (screenSize.width - 24.0).clamp(320.0, 480.0)
        : (screenSize.width * 0.48).clamp(400.0, 540.0);

    final safeTop = safePadding.top + 10.0;
    final safeBottom = screenSize.height - safePadding.bottom - viewInsets.bottom - 10.0;
    final availableHeight = (safeBottom - safeTop).clamp(240.0, screenSize.height);
    final maxCardHeight = (availableHeight * 0.70).clamp(320.0, 560.0);

    final spaceAbove = targetRect.top - safeTop;
    final spaceBelow = safeBottom - targetRect.bottom;
    final spaceLeft = targetRect.left;
    final spaceRight = screenSize.width - targetRect.right;

    final pref = widget.step.preferredPosition;
    bool placeBelow;
    TooltipPointerDirection pointerDirection = TooltipPointerDirection.none;

    // Check side placements first if explicitly requested and space permits
    if (pref == TooltipPosition.right && spaceRight >= cardWidth + 16.0) {
      final left = (targetRect.right + 10.0).clamp(10.0, screenSize.width - cardWidth - 10.0);
      final top = (targetRect.center.dy - maxCardHeight / 2).clamp(safeTop, safeBottom - maxCardHeight);
      return Positioned(
        left: left,
        top: top,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: WalkthroughTooltip(
            step: widget.step,
            currentStepIndex: widget.currentStepIndex,
            totalSteps: widget.totalSteps,
            onBack: widget.onBack,
            onNext: widget.onNext,
            onClose: widget.onClose,
            onSkip: widget.onSkip,
            onExploreInDepth: widget.onExploreInDepth,
            onRunDemo: widget.onRunDemo,
            pointerDirection: TooltipPointerDirection.left,
          ),
        ),
      );
    } else if (pref == TooltipPosition.left && spaceLeft >= cardWidth + 16.0) {
      final left = (targetRect.left - cardWidth - 10.0).clamp(10.0, screenSize.width - cardWidth - 10.0);
      final top = (targetRect.center.dy - maxCardHeight / 2).clamp(safeTop, safeBottom - maxCardHeight);
      return Positioned(
        left: left,
        top: top,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: WalkthroughTooltip(
            step: widget.step,
            currentStepIndex: widget.currentStepIndex,
            totalSteps: widget.totalSteps,
            onBack: widget.onBack,
            onNext: widget.onNext,
            onClose: widget.onClose,
            onSkip: widget.onSkip,
            onExploreInDepth: widget.onExploreInDepth,
            onRunDemo: widget.onRunDemo,
            pointerDirection: TooltipPointerDirection.right,
          ),
        ),
      );
    }

    // Determine vertical placement
    if (pref == TooltipPosition.top) {
      if (spaceAbove >= 200.0 || spaceAbove >= spaceBelow) {
        placeBelow = false;
      } else {
        placeBelow = true;
      }
    } else if (pref == TooltipPosition.bottom) {
      if (spaceBelow >= 200.0 || spaceBelow >= spaceAbove) {
        placeBelow = true;
      } else {
        placeBelow = false;
      }
    } else {
      // Auto or Center
      if (spaceBelow >= maxCardHeight + 16.0) {
        placeBelow = true;
      } else if (spaceAbove >= maxCardHeight + 16.0) {
        placeBelow = false;
      } else {
        placeBelow = spaceBelow >= spaceAbove;
      }
    }

    // Calculate clamped vertical position
    double top;
    if (placeBelow) {
      top = targetRect.bottom + 10.0;
      if (top + maxCardHeight > safeBottom) {
        if (spaceAbove > spaceBelow + 40.0) {
          placeBelow = false;
          top = (targetRect.top - maxCardHeight - 10.0).clamp(safeTop, safeBottom - maxCardHeight);
        } else {
          top = (safeBottom - maxCardHeight).clamp(safeTop, safeBottom);
        }
      }
    } else {
      top = targetRect.top - maxCardHeight - 10.0;
      if (top < safeTop) {
        if (spaceBelow > spaceAbove + 40.0) {
          placeBelow = true;
          top = (safeBottom - maxCardHeight).clamp(safeTop, safeBottom);
        } else {
          top = safeTop;
        }
      }
    }

    // Determine arrow direction
    if (placeBelow && targetRect.bottom <= top + 15.0) {
      pointerDirection = TooltipPointerDirection.top;
    } else if (!placeBelow && targetRect.top >= top + maxCardHeight - 15.0) {
      pointerDirection = TooltipPointerDirection.bottom;
    } else {
      pointerDirection = TooltipPointerDirection.none;
    }

    // Calculate clamped horizontal position
    final left = (targetRect.center.dx - cardWidth / 2).clamp(10.0, screenSize.width - cardWidth - 10.0);
    final pointerOffset = ((targetRect.center.dx - left) / cardWidth).clamp(0.12, 0.88);

    return Positioned(
      left: left,
      top: top,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: WalkthroughTooltip(
          step: widget.step,
          currentStepIndex: widget.currentStepIndex,
          totalSteps: widget.totalSteps,
          onBack: widget.onBack,
          onNext: widget.onNext,
          onClose: widget.onClose,
          onSkip: widget.onSkip,
          onExploreInDepth: widget.onExploreInDepth,
          onRunDemo: widget.onRunDemo,
          pointerDirection: pointerDirection,
          pointerHorizontalOffset: pointerOffset,
        ),
      ),
    );
  }
}

/// Custom painter rendering the spotlight cutout and glowing border.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.targetRect,
    required this.spotlightRadius,
    required this.overlayColor,
    required this.glowColor,
    required this.animValue,
  });

  final Rect? targetRect;
  final double spotlightRadius;
  final Color overlayColor;
  final Color glowColor;
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    final screenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect == null) {
      canvas.drawPath(screenPath, Paint()..color = overlayColor);
      return;
    }

    final cutoutRRect = RRect.fromRectAndRadius(
      targetRect!,
      Radius.circular(spotlightRadius),
    );

    final cutoutPath = Path()..addRRect(cutoutRRect);

    // Subtract cutout from dark overlay
    final combinedPath = Path.combine(
      PathOperation.difference,
      screenPath,
      cutoutPath,
    );

    canvas.drawPath(combinedPath, Paint()..color = overlayColor);

    // Draw pulsating outer glow ring
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.35 + (math.sin(animValue * math.pi) * 0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6.0);

    canvas.drawRRect(cutoutRRect, glowPaint);

    // Draw crisp inner border
    final strokePaint = Paint()
      ..color = glowColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawRRect(cutoutRRect, strokePaint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.animValue != animValue ||
        oldDelegate.overlayColor != overlayColor;
  }
}

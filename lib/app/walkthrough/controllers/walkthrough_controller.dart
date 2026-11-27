import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/walkthrough_sequence.dart';
import '../models/walkthrough_step.dart';
import '../sequences/app_walkthrough_catalog.dart';
import '../services/walkthrough_progress_service.dart';
import '../services/walkthrough_registry.dart';
import '../services/walkthrough_voice_service.dart';
import '../views/walkthrough_overlay.dart';

/// Master controller orchestrating application walkthroughs, overlay lifecycle,
/// route transitions, spotlight calculations, and module deep dives.
class WalkthroughController extends GetxController {
  static WalkthroughController get to => Get.find<WalkthroughController>();

  final activeSequence = Rx<WalkthroughSequence?>(null);
  final currentStepIndex = 0.obs;
  final currentTargetRect = Rx<Rect?>(null);

  final List<String> _tourStack = [];

  OverlayEntry? _overlayEntry;
  bool _isTransitioning = false;

  bool get isTourActive => activeSequence.value != null;

  WalkthroughStep? get currentStep {
    final seq = activeSequence.value;
    if (seq == null) return null;
    if (currentStepIndex.value < 0 || currentStepIndex.value >= seq.steps.length) {
      return null;
    }
    return seq.steps[currentStepIndex.value];
  }

  @override
  void onInit() {
    super.onInit();
    // Register Voice Service if not already present
    if (!Get.isRegistered<WalkthroughVoiceService>()) {
      Get.put(WalkthroughVoiceService(), permanent: true);
    }
  }

  /// Automatically check and initiate first-time onboarding tour if user hasn't seen it yet.
  Future<void> checkFirstTimeOnboarding({
    Duration delay = const Duration(milliseconds: 600),
    bool force = false,
  }) async {
    final isFirst = force || await WalkthroughProgressService.instance.isFirstTime();
    if (isFirst && !isTourActive) {
      await Future.delayed(delay);
      if (!isTourActive) {
        startTour(AppWalkthroughCatalog.mainTourId);
      }
    }
  }

  /// Launches a walkthrough tour by ID.
  Future<void> startTour(String tourId, {int? stepIndex, bool pushToStack = false}) async {
    final seq = AppWalkthroughCatalog.findSequenceById(tourId);
    if (seq == null || seq.steps.isEmpty) {
      debugPrint('[WalkthroughController] Tour sequence "$tourId" not found.');
      return;
    }

    if (pushToStack && activeSequence.value != null) {
      _tourStack.add(activeSequence.value!.id);
    } else if (!pushToStack) {
      _tourStack.clear();
    }

    activeSequence.value = seq;
    currentStepIndex.value = stepIndex ?? 0;

    await _displayCurrentStep();
  }

  /// Advances to the next step or finishes the tour on the final step.
  Future<void> nextStep() async {
    if (_isTransitioning) return;
    final seq = activeSequence.value;
    final step = currentStep;
    if (seq == null || step == null) return;

    _isTransitioning = true;
    if (step.onStepExit != null) {
      try {
        await step.onStepExit!();
      } catch (e) {
        debugPrint('[WalkthroughController] Error in onStepExit: $e');
      }
    }

    if (currentStepIndex.value < seq.steps.length - 1) {
      currentStepIndex.value++;
      await WalkthroughProgressService.instance.saveCurrentStep(seq.id, currentStepIndex.value);
      await _displayCurrentStep();
    } else {
      await finishTour();
    }
    _isTransitioning = false;
  }

  /// Moves back to the previous step.
  Future<void> previousStep() async {
    if (_isTransitioning || currentStepIndex.value <= 0) return;
    final step = currentStep;
    if (step == null) return;

    _isTransitioning = true;
    if (step.onStepExit != null) {
      try {
        await step.onStepExit!();
      } catch (e) {
        debugPrint('[WalkthroughController] Error in onStepExit: $e');
      }
    }

    currentStepIndex.value--;
    final seq = activeSequence.value;
    if (seq != null) {
      await WalkthroughProgressService.instance.saveCurrentStep(seq.id, currentStepIndex.value);
    }
    await _displayCurrentStep();
    _isTransitioning = false;
  }

  /// Branches into a detailed module walkthrough ("Explore in Depth").
  Future<void> exploreInDepth(String moduleId) async {
    debugPrint('[WalkthroughController] Branching into Explore in Depth: $moduleId');
    await startTour(moduleId, pushToStack: true);
  }

  /// Completes the current tour and returns to parent tour if one was open.
  Future<void> finishTour() async {
    final seq = activeSequence.value;
    if (seq != null) {
      await WalkthroughProgressService.instance.markTourCompleted(seq.id);
      await WalkthroughProgressService.instance.clearLastStep(seq.id);
    }

    if (_tourStack.isNotEmpty) {
      final parentTourId = _tourStack.removeLast();
      debugPrint('[WalkthroughController] Returning to parent tour: $parentTourId');
      final savedStep = await WalkthroughProgressService.instance.getLastStep(parentTourId);
      await startTour(parentTourId, stepIndex: savedStep);
      return;
    }

    _dismissOverlay();
    activeSequence.value = null;
    currentStepIndex.value = 0;
  }

  /// Skips and dismisses the walkthrough cleanly.
  Future<void> skipTour() async {
    final seq = activeSequence.value;
    if (seq != null) {
      await WalkthroughProgressService.instance.markTourCompleted(seq.id);
      await WalkthroughProgressService.instance.clearLastStep(seq.id);
    }
    _tourStack.clear();
    _dismissOverlay();
    activeSequence.value = null;
    currentStepIndex.value = 0;
  }

  /// Safely executes an interactive demonstration on the current step.
  Future<void> runInteractiveDemo() async {
    final step = currentStep;
    if (step?.interactiveDemo != null) {
      try {
        await step!.interactiveDemo!();
      } catch (e) {
        debugPrint('[WalkthroughController] Error in interactiveDemo: $e');
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // OVERLAY & STEP RENDERING
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _displayCurrentStep() async {
    final step = currentStep;
    if (step == null) return;

    // 1. Ensure application is on the target route if required
    if (step.targetRoute != null && Get.currentRoute != step.targetRoute) {
      debugPrint('[WalkthroughController] Navigating to required route: ${step.targetRoute}');
      Get.offAllNamed(step.targetRoute!);
      // Allow frame rendering on new route
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // 2. Execute onStepEnter callback
    if (step.onStepEnter != null) {
      try {
        await step.onStepEnter!();
      } catch (e) {
        debugPrint('[WalkthroughController] Error in onStepEnter: $e');
      }
    }

    // 3. Scroll target widget into visible viewport
    if (step.targetKeyName != null) {
      await WalkthroughRegistry.instance.ensureVisible(step.targetKeyName!);
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // 4. Measure target widget geometry
    Rect? rect;
    if (step.targetKeyName != null) {
      rect = WalkthroughRegistry.instance.getTargetRect(step.targetKeyName!);
      // If not yet available, retry after one postFrameCallback
      if (rect == null) {
        final completer = Completer<Rect?>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          completer.complete(WalkthroughRegistry.instance.getTargetRect(step.targetKeyName!));
        });
        rect = await completer.future;
      }
    }
    currentTargetRect.value = rect;

    // 5. Narrate step audio if voice is enabled
    if (Get.isRegistered<WalkthroughVoiceService>()) {
      Get.find<WalkthroughVoiceService>().speak(step.effectiveVoiceScript);
    }

    // 6. Mount or update overlay entry
    _updateOverlay();
  }

  OverlayState? _resolveOverlayState() {
    // 1. Root Navigator Overlay (Most reliable in GetMaterialApp)
    final navState = Get.key.currentState;
    if (navState?.overlay != null) {
      return navState!.overlay;
    }
    // 2. Element Context Overlay
    final ctx = Get.context;
    if (ctx != null) {
      final nav = Navigator.maybeOf(ctx);
      if (nav?.overlay != null) return nav!.overlay;
      final ov = Overlay.maybeOf(ctx);
      if (ov != null) return ov;
    }
    // 3. Overlay Context
    final overlayCtx = Get.overlayContext;
    if (overlayCtx != null) {
      final nav = Navigator.maybeOf(overlayCtx);
      if (nav?.overlay != null) return nav!.overlay;
      final ov = Overlay.maybeOf(overlayCtx);
      if (ov != null) return ov;
    }
    return null;
  }

  void _updateOverlay({int retryCount = 0}) {
    final overlayState = _resolveOverlayState();

    if (overlayState == null) {
      if (retryCount < 8) {
        debugPrint('[WalkthroughController] OverlayState not ready yet, retrying (attempt $retryCount)...');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 120), () {
            _updateOverlay(retryCount: retryCount + 1);
          });
        });
      } else {
        debugPrint('[WalkthroughController] OverlayState could not be found after retries.');
      }
      return;
    }

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Obx(() {
          final step = currentStep;
          final seq = activeSequence.value;
          if (step == null || seq == null) return const SizedBox.shrink();

          return WalkthroughOverlay(
            step: step,
            currentStepIndex: currentStepIndex.value,
            totalSteps: seq.steps.length,
            targetRect: currentTargetRect.value,
            onBack: currentStepIndex.value > 0 ? previousStep : null,
            onNext: nextStep,
            onClose: skipTour,
            onSkip: skipTour,
            onExploreInDepth: step.exploreModuleId != null
                ? () => exploreInDepth(step.exploreModuleId!)
                : null,
            onRunDemo: step.interactiveDemo != null ? runInteractiveDemo : null,
          );
        }),
      );
      overlayState.insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _dismissOverlay() {
    if (Get.isRegistered<WalkthroughVoiceService>()) {
      Get.find<WalkthroughVoiceService>().stop();
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    currentTargetRect.value = null;
  }

  @override
  void onClose() {
    _dismissOverlay();
    super.onClose();
  }
}

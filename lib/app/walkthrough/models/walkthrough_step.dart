import 'dart:async';
import 'package:flutter/material.dart';

/// Categories of walkthrough steps for visual badge styling.
enum WalkthroughCategory {
  welcome('Welcome', Icons.waving_hand_rounded, Color(0xFF3B82F6)),
  navigation('Navigation', Icons.navigation_rounded, Color(0xFF6366F1)),
  analytics('Analytics & KPIs', Icons.bar_chart_rounded, Color(0xFF10B981)),
  workflow('Workflow', Icons.account_tree_rounded, Color(0xFF8B5CF6)),
  action('Quick Action', Icons.touch_app_rounded, Color(0xFFF59E0B)),
  feature('Feature Tour', Icons.star_rounded, Color(0xFF0EA5E9));

  const WalkthroughCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// Preferred placement of the tooltip relative to the spotlight target.
enum TooltipPosition {
  auto,
  top,
  bottom,
  left,
  right,
  center,
}

/// Model representing a single walkthrough step.
class WalkthroughStep {
  const WalkthroughStep({
    required this.id,
    required this.title,
    required this.description,
    this.category = WalkthroughCategory.feature,
    this.tips,
    this.actionInstruction,
    this.targetKeyName,
    this.spotlightRadius = 12.0,
    this.spotlightPadding = const EdgeInsets.all(8.0),
    this.preferredPosition = TooltipPosition.auto,
    this.targetRoute,
    this.exploreModuleId,
    this.exploreTitle,
    this.deepDivePrompt,
    this.deepDiveMinutes,
    this.deepDiveButtonLabel,
    this.badgeText,
    this.showArrow = true,
    this.onStepEnter,
    this.onStepExit,
    this.actionBefore,
    this.actionAfter,
    this.interactiveDemo,
    this.voiceScript,
  });

  /// Unique identifier for this step.
  final String id;

  /// Main title of the feature or control.
  final String title;

  /// In-depth user-facing explanation of what the feature does and how to use it.
  final String description;

  /// Category tag for badge styling.
  final WalkthroughCategory category;

  /// Optional helpful tips or best practices for the user.
  final String? tips;

  /// Optional actionable prompt instructing the user what to do next.
  final String? actionInstruction;

  /// Name of the registered target widget key in [WalkthroughRegistry].
  /// If null or target cannot be found, tooltip displays in center as an intro/outro modal.
  final String? targetKeyName;

  /// Border radius of the spotlight cutout around the target widget.
  final double spotlightRadius;

  /// Padding around the target widget within the spotlight cutout.
  final EdgeInsets spotlightPadding;

  /// Preferred direction for the tooltip relative to the target.
  final TooltipPosition preferredPosition;

  /// Target route where this step is visible (e.g. AppRoutes.dashboard).
  /// If specified and the app is on a different route, the walkthrough engine will navigate there.
  final String? targetRoute;

  /// If this step has a deeper module walkthrough, specify its sequence ID here.
  /// When present, an "Explore in Depth" action button will be rendered.
  final String? exploreModuleId;

  /// Label for the explore button (e.g. "Explore Dashboard in Depth").
  final String? exploreTitle;

  /// Question prompt displayed above the deep dive button (e.g. "Want to inspect jobsite bill of materials...?").
  final String? deepDivePrompt;

  /// Estimated duration in minutes for the deep dive tour.
  final int? deepDiveMinutes;

  /// Optional custom button label override.
  final String? deepDiveButtonLabel;

  /// Optional status pill override (defaults to Voice status).
  final String? badgeText;

  /// Whether to render a pointer arrow pointing to the target.
  final bool showArrow;

  /// Optional callback executed when entering this step.
  final FutureOr<void> Function()? onStepEnter;

  /// Optional callback executed when leaving this step.
  final FutureOr<void> Function()? onStepExit;

  /// Optional action callback executed before displaying this step (e.g. opening the drawer).
  final FutureOr<void> Function()? actionBefore;

  /// Optional action callback executed after leaving this step (e.g. closing the drawer).
  final FutureOr<void> Function()? actionAfter;

  /// Optional safe interactive demonstration callback (e.g. open dropdown, highlight tab).
  final Future<void> Function()? interactiveDemo;

  /// Optional custom voice narration text. Defaults to "$title. $description".
  final String? voiceScript;

  /// Whether this step offers a deeper module exploration.
  bool get hasDeepDive =>
      (exploreModuleId != null && exploreModuleId!.isNotEmpty) ||
      (exploreTitle != null && exploreTitle!.isNotEmpty) ||
      (deepDiveButtonLabel != null && deepDiveButtonLabel!.isNotEmpty);

  /// Resolved explore CTA button text.
  String get resolvedExploreButtonLabel {
    if (deepDiveButtonLabel != null && deepDiveButtonLabel!.isNotEmpty) {
      return deepDiveButtonLabel!;
    }
    final mins = deepDiveMinutes != null ? ' ($deepDiveMinutes min)' : '';
    if (exploreTitle != null && exploreTitle!.isNotEmpty) {
      if (exploreTitle!.contains('min')) return exploreTitle!;
      return '$exploreTitle$mins';
    }
    return 'Explore in Depth$mins';
  }

  /// Resolved voice narration script.
  String get effectiveVoiceScript =>
      voiceScript ?? '$title. $description${tips != null ? ". Tip: $tips" : ""}';
}

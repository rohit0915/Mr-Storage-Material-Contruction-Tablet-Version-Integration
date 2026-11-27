import 'walkthrough_step.dart';

/// Represents an entire walkthrough journey or module tour.
class WalkthroughSequence {
  const WalkthroughSequence({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    this.route,
    this.parentTourId,
    this.badgeText,
  });

  /// Unique sequence identifier (e.g. 'main_tour', 'dashboard_tour').
  final String id;

  /// Human-readable title of the tour.
  final String title;

  /// Brief overview of what this tour covers.
  final String description;

  /// Ordered list of steps included in this tour.
  final List<WalkthroughStep> steps;

  /// Default application route where this sequence takes place.
  final String? route;

  /// Parent tour ID if this is a nested "Explore in Depth" tour.
  final String? parentTourId;

  /// Optional badge text (e.g. "Primary", "Module", "Workflow").
  final String? badgeText;

  int get totalSteps => steps.length;
}

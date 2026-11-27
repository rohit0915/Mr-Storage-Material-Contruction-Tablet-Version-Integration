import 'package:shared_preferences/shared_preferences.dart';

/// Service managing persistent progress for all walkthrough journeys.
class WalkthroughProgressService {
  WalkthroughProgressService._();

  static final WalkthroughProgressService instance =
      WalkthroughProgressService._();

  static const String _keyFirstTimeTourDone = 'walkthrough_first_time_completed';
  static const String _keyCompletedToursPrefix = 'walkthrough_completed_';
  static const String _keyLastStepPrefix = 'walkthrough_last_step_';
  static const String _keyVoiceEnabled = 'walkthrough_voice_enabled';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if the user has never completed the main application tour.
  Future<bool> isFirstTime() async {
    await init();
    return !(_prefs?.getBool(_keyFirstTimeTourDone) ?? false);
  }

  /// Mark the main onboarding walkthrough as completed.
  Future<void> markFirstTimeCompleted() async {
    await init();
    await _prefs?.setBool(_keyFirstTimeTourDone, true);
  }

  /// Check if a specific module sequence has been completed.
  Future<bool> hasCompletedTour(String tourId) async {
    await init();
    return _prefs?.getBool('$_keyCompletedToursPrefix$tourId') ?? false;
  }

  /// Mark a specific module sequence as completed.
  Future<void> markTourCompleted(String tourId) async {
    await init();
    await _prefs?.setBool('$_keyCompletedToursPrefix$tourId', true);
    if (tourId == 'main_tour') {
      await markFirstTimeCompleted();
    }
  }

  /// Save the current step index to allow resuming later.
  Future<void> saveCurrentStep(String tourId, int stepIndex) async {
    await init();
    await _prefs?.setInt('$_keyLastStepPrefix$tourId', stepIndex);
  }

  /// Get the last saved step index for a tour (defaults to 0).
  Future<int> getLastStep(String tourId) async {
    await init();
    return _prefs?.getInt('$_keyLastStepPrefix$tourId') ?? 0;
  }

  /// Clear the saved resume step for a tour.
  Future<void> clearLastStep(String tourId) async {
    await init();
    await _prefs?.remove('$_keyLastStepPrefix$tourId');
  }

  /// Check if voice guidance is enabled.
  Future<bool> isVoiceEnabled() async {
    await init();
    return _prefs?.getBool(_keyVoiceEnabled) ?? true;
  }

  /// Toggle or set voice guidance preference.
  Future<void> setVoiceEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyVoiceEnabled, enabled);
  }

  /// Reset all walkthrough progress (for replaying from Settings / Help).
  Future<void> resetAll() async {
    await init();
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('walkthrough_')) {
        await _prefs?.remove(key);
      }
    }
  }
}

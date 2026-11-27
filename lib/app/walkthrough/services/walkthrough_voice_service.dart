import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'walkthrough_progress_service.dart';

/// Real device audio Text-To-Speech (TTS) voice service.
/// Uses [FlutterTts] for audible device speech with fallback timing.
class WalkthroughVoiceService extends GetxService {
  final isSpeaking = false.obs;
  final isVoiceEnabled = true.obs;
  final currentNarratingText = ''.obs;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;
  Timer? _speechTimer;

  @override
  Future<void> onInit() async {
    super.onInit();
    final enabled = await WalkthroughProgressService.instance.isVoiceEnabled();
    isVoiceEnabled.value = enabled;
    await _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.awaitSpeakCompletion(true);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final engines = await _flutterTts.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _flutterTts.setEngine('com.google.android.tts');
          }
        } catch (_) {}
      }

      try {
        final isUsAvailable = await _flutterTts.isLanguageAvailable('en-US');
        if (isUsAvailable == 1 || isUsAvailable == true) {
          await _flutterTts.setLanguage('en-US');
        } else {
          final isInAvailable = await _flutterTts.isLanguageAvailable('en-IN');
          if (isInAvailable == 1 || isInAvailable == true) {
            await _flutterTts.setLanguage('en-IN');
          } else {
            final langs = await _flutterTts.getLanguages;
          if (langs is List && langs.isNotEmpty) {
            await _flutterTts.setLanguage(langs.first.toString());
          }
            
          }
        }
      } catch (_) {
        try {
          await _flutterTts.setLanguage('en-US');
        } catch (_) {}
      }

      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        isSpeaking.value = true;
      });

      _flutterTts.setCompletionHandler(() {
        isSpeaking.value = false;
        currentNarratingText.value = '';
        _speechTimer?.cancel();
      });

      _flutterTts.setCancelHandler(() {
        isSpeaking.value = false;
        currentNarratingText.value = '';
        _speechTimer?.cancel();
      });

      _flutterTts.setErrorHandler((dynamic _) {
        isSpeaking.value = false;
        currentNarratingText.value = '';
        _speechTimer?.cancel();
      });

      _isTtsInitialized = true;
    } catch (_) {
      _isTtsInitialized = false;
    }
  }

  /// Sets voice guidance enabled or disabled and persists the setting.
  Future<void> setVoiceEnabled(bool enabled) async {
    isVoiceEnabled.value = enabled;
    await WalkthroughProgressService.instance.setVoiceEnabled(enabled);
    if (!enabled) {
      stop();
    }
  }

  /// Toggles voice guidance on or off.
  Future<void> toggleVoice() async {
    await setVoiceEnabled(!isVoiceEnabled.value);
  }

  /// Starts narrating the given [script].
  /// Stops any currently active narration before speaking.
  Future<void> speak(String script) async {
    stop();

    if (!isVoiceEnabled.value || script.trim().isEmpty) {
      return;
    }

    currentNarratingText.value = script;
    isSpeaking.value = true;

    if (!_isTtsInitialized) {
      await _initTts();
    }

    if (_isTtsInitialized) {
      try {
        await _flutterTts.stop();
        await Future.delayed(const Duration(milliseconds: 60));
        final result = await _flutterTts.speak(script, focus: true);
        if (result == 1) {
          return;
        }
      } catch (e) {
        debugPrint('[WalkthroughVoiceService] FlutterTts.speak error: $e');
      }
    }

    // Fallback timer if platform TTS is unavailable or in unit tests
    final wordCount = script.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final estimatedDurationMs = max(2400, (wordCount * 280));

    _speechTimer?.cancel();
    _speechTimer = Timer(Duration(milliseconds: estimatedDurationMs), () {
      isSpeaking.value = false;
      currentNarratingText.value = '';
    });
  }

  /// Immediately stops any ongoing speech narration.
  void stop() {
    if (_isTtsInitialized) {
      try {
        _flutterTts.stop().catchError((_) {});
      } catch (_) {}
    }
    _speechTimer?.cancel();
    _speechTimer = null;
    isSpeaking.value = false;
    currentNarratingText.value = '';
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}

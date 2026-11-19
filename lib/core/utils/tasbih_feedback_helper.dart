import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class TasbihFeedbackHelper {
  static final TasbihFeedbackHelper _instance = TasbihFeedbackHelper._internal();
  factory TasbihFeedbackHelper() => _instance;
  TasbihFeedbackHelper._internal();

  AudioPlayer? _clickPlayer;
  AudioPlayer? _targetPlayer;
  bool _isAudioReady = false;

  Future<void> init() async {
    if (_isAudioReady) return;
    try {
      _clickPlayer = AudioPlayer();
      await _clickPlayer!.setAsset('assets/audio/tasbih_click.wav');
      await _clickPlayer!.setVolume(1.0);

      _targetPlayer = AudioPlayer();
      await _targetPlayer!.setAsset('assets/audio/tasbih_target.wav');
      await _targetPlayer!.setVolume(1.0);

      _isAudioReady = true;
    } catch (e) {
      debugPrint('TasbihFeedbackHelper init audio fallback: $e');
    }
  }

  /// Memainkan getaran dan suara setiap kali tasbih diketuk
  Future<void> playTapFeedback({
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    // 1. Getaran Haptic Android
    if (vibrationEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (e) {
        debugPrint('HapticFeedback error: $e');
      }
    }

    // 2. Efek Suara
    if (soundEnabled) {
      try {
        if (_isAudioReady && _clickPlayer != null) {
          // Putar dari awal tanpa jeda
          await _clickPlayer!.seek(Duration.zero);
          _clickPlayer!.play();
        } else {
          // Fallback native click
          SystemSound.play(SystemSoundType.click);
        }
      } catch (e) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  /// Memainkan getaran dan suara spesial ketika target dzikir tercapai
  Future<void> playTargetReachedFeedback({
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    // 1. Getaran Kuat Khusus Target Tercapai
    if (vibrationEnabled) {
      try {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 120), () {
          HapticFeedback.heavyImpact();
        });
        Future.delayed(const Duration(milliseconds: 240), () {
          HapticFeedback.mediumImpact();
        });
      } catch (e) {
        debugPrint('HapticFeedback target error: $e');
      }
    }

    // 2. Suara Chime Target Tercapai
    if (soundEnabled) {
      try {
        if (_isAudioReady && _targetPlayer != null) {
          await _targetPlayer!.seek(Duration.zero);
          _targetPlayer!.play();
        } else {
          SystemSound.play(SystemSoundType.alert);
        }
      } catch (e) {
        SystemSound.play(SystemSoundType.alert);
      }
    }
  }

  void dispose() {
    _clickPlayer?.dispose();
    _targetPlayer?.dispose();
  }
}

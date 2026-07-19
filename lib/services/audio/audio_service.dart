import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound effect types
enum SoundEffect {
  click,
  correct,
  wrong,
  levelComplete,
  wordFound,
  bonusWord,
  coin,
  hint,
  error,
  button,
  pop,
  whoosh,
  pop2,
  sparkles,
}

class AudioService {
  AudioService() {
    _init();
  }

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 1.0;
  double _musicVolume = 0.5;
  bool _initialized = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  set soundEnabled(bool value) => _soundEnabled = value;
  set musicEnabled(bool value) {
    _musicEnabled = value;
    if (!value) {
      _musicPlayer.pause();
    }
  }

  Future<void> _init() async {
    if (_initialized) return;
    try {
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Audio init error: $e');
      }
    }
  }

  /// Play a sound effect
  Future<void> playSfx(SoundEffect effect) async {
    if (!_soundEnabled) return;
    try {
      // In a real app, you'd map effect -> asset file
      // _sfxPlayer.play(AssetSource('sounds/${_assetFor(effect)}.mp3'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Play SFX error: $e');
      }
    }
  }

  /// Play background music
  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Play music error: $e');
      }
    }
  }

  /// Stop music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  /// Pause music
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  /// Resume music
  Future<void> resumeMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }

  /// Set volumes
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }

  /// Mute/unmute
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      stopMusic();
    }
  }

  Future<void> dispose() async {
    try {
      await _sfxPlayer.dispose();
      await _musicPlayer.dispose();
    } catch (_) {}
  }
}

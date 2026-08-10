import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Short, local, generated tones for word-found / level-complete feedback,
/// paired with haptics. No network, no third-party assets, no user setting
/// to fight over -- if a device is silenced the OS mutes it for us; if
/// playback ever fails (missing audio hardware, headless test runner) it
/// fails silently rather than crashing gameplay.
class SoundService {
  final AudioPlayer _player = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

  Future<void> wordFound() async {
    HapticFeedback.lightImpact();
    _playFireAndForget('sounds/found.wav');
  }

  Future<void> levelComplete() async {
    HapticFeedback.mediumImpact();
    _playFireAndForget('sounds/complete.wav');
  }

  void _playFireAndForget(String assetPath) {
    _player.play(AssetSource(assetPath)).catchError((_) {});
  }

  void dispose() {
    _player.dispose();
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});

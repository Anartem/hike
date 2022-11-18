import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioUseCase implements Disposable {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamSink<Food>? get sink => _player.foodSink;

  AudioUseCase() {
    _player.openPlayer();
  }

  Future<void> startPlay() {
    return _player.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 44100);
  }

  Future<void> stopPlay() {
    return _player.stopPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
  }
}
import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_sound/flutter_sound.dart';

class MicUseCase implements Disposable {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  final StreamController<Food> _dataController = StreamController.broadcast();
  StreamSink<Food> get _dataSink => _dataController.sink;
  Stream<Food> get dataStream => _dataController.stream;

  MicUseCase() {
    _recorder.openRecorder();
  }

  Future<void> startRecord() {
    return _recorder.startRecorder(toStream: _dataSink, codec: Codec.pcm16, numChannels: 1, sampleRate: 44100,);
  }

  Future<void> stopRecord() {
    return _recorder.stopRecorder();
  }

  @override
  void dispose() {
    _dataController.close();
    _recorder.closeRecorder();
  }
}
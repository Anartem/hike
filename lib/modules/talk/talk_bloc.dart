import 'dart:async';
import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hike_radio/bl/data_provider.dart';
import 'package:hike_radio/bl/socket_client.dart';
import 'package:hike_radio/bl/socket_server.dart';
import 'package:hike_radio/bl/use_cases/audio_use_case.dart';
import 'package:hike_radio/bl/use_cases/location_use_case.dart';
import 'package:hike_radio/bl/use_cases/mic_use_case.dart';
import 'package:hike_radio/models/location_model.dart';
import 'package:hike_radio/models/talk_chunk_model.dart';
import 'package:hike_radio/models/talk_enable_model.dart';
import 'package:rxdart/rxdart.dart';

enum Role {
  client,
  server,
  undefined,
}

class TalkBloc implements Disposable {
  final AudioUseCase _audioUseCase;
  final MicUseCase _micUseCase;
  final LocationUseCase _locationUseCase;

  final BehaviorSubject<bool> _statusController = BehaviorSubject();
  Stream<bool> get statusStream => _statusController.stream;

  final BehaviorSubject<bool> _talkController = BehaviorSubject();
  Stream<bool> get talkStream => _talkController.stream;
  late StreamSubscription<Food> _micSubscription;

  final StreamController<Iterable<LocationModel>> _locationController = StreamController.broadcast();
  Stream<Iterable<LocationModel>> get locationStream => _locationController.stream;
  Stream<LocationStatus> get locationStatusStream => _locationUseCase.statusStream;
  late StreamSubscription<LocationModel> _locationSubscription;

  final BehaviorSubject<Role> _roleController = BehaviorSubject();
  Stream<Role> get roleStream => _roleController.stream;

  Role get role => _dataProvider is SocketServer
      ? Role.server
      : _dataProvider is SocketClient
          ? Role.client
          : Role.undefined;

  DataProvider? _dataProvider;

  TalkBloc(this._micUseCase, this._audioUseCase, this._locationUseCase) {
    _locationSubscription = _locationUseCase.dataStream.listen((data) => _dataProvider?.setLocation(data));
    _micSubscription = _micUseCase.dataStream.listen((event) {
      if (event is FoodData && event.data != null) {
        _dataProvider?.setTalkChunk(TalkChunkModel(chunk: event.data!.toList()));
      }
    });
  }

  Future<String> getIp() async {
    List<NetworkInterface> list = await NetworkInterface.list();
    return list.firstWhere((element) => element.name == "wlan0").addresses.first.address;
  }

  void checkLocationPermission(bool request) {
    _locationUseCase.checkPermission(request);
  }

  void startClient(String address) async {
    await _audioUseCase.startPlay();

    _dataProvider = SocketClient()
      ..onTalkEnabled = _talkController.add
      ..onLocation = _locationController.add
      ..onTalkChunk = _audioUseCase.sink?.add
      ..onStatus = _statusController.add
      ..start(address);

    _roleController.add(Role.client);
  }

  void startServer() async {
    await _audioUseCase.startPlay();

    _dataProvider = SocketServer()
      ..onTalkEnabled = _talkController.add
      ..onLocation = _locationController.add
      ..onTalkChunk = _audioUseCase.sink?.add
      ..onStatus = _statusController.add
      ..start();

    _roleController.add(Role.server);
  }

  void stop() {
    _audioUseCase.stopPlay();
    _dataProvider?.stop();
    _dataProvider = null;

    _statusController.add(false);
    _roleController.add(Role.undefined);
  }

  void startTalk() {
    _dataProvider?.setTalk(TalkEnableModel(enable: true));
    _micUseCase.startRecord();
  }

  void stopTalk() {
    _dataProvider?.setTalk(TalkEnableModel(enable: false));
    _micUseCase.stopRecord();
  }

  @override
  void dispose() {
    _statusController.close();
    _talkController.close();
    _locationController.close();
    _locationSubscription.cancel();
    _micSubscription.cancel();
  }
}

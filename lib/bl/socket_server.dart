import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:hike_radio/bl/data_provider.dart';
import 'package:hike_radio/models/location_model.dart';
import 'package:hike_radio/models/talk_chunk_model.dart';
import 'package:hike_radio/models/talk_enable_model.dart';
import 'package:socket_io/socket_io.dart';

class SocketServer extends DataProvider {
  static const _port = 3000;

  late final Server _server;

  int _talkId = 0;
  final Map<int, LocationModel> _map = {};

  SocketServer() {
    _init();
  }

  void _init() {
    _server = Server();

    _server.on('connection', (client) {
      client.emit('talkId', _talkId);

      client.on('location', (data) {
        LocationModel model = LocationModel.fromJson(data);
        setLocation(model);
      });

      client.on('talk', (data) {
        TalkEnableModel model = TalkEnableModel.fromJson(data);
        setTalk(model);
      });

      client.on('chunk', (data) {
        TalkChunkModel model = TalkChunkModel.fromJson(data);
        setTalkChunk(model);
      });
    });
  }

  void start() async {
    await _server.listen(_port);
    onStatus?.call(true);
    onTalkEnabled?.call(true);
  }

  @override
  void stop() {
    _server.close();
  }

  @override
  void setLocation(LocationModel model) {
    _map[model.id] = model;
    _server.emit('location', jsonEncode(_map.values.map((i) => i.toJson()).toList()));
    onLocation?.call(_map.values);
  }

  @override
  void setTalk(TalkEnableModel model) {
    if (_talkId == model.id && !model.enable) {
      _talkId = 0;
    } else if (_talkId == 0 && model.enable) {
      _talkId = model.id;
    }
    _server.emit("talkId", _talkId);
    onTalkEnabled?.call(_talkId == DataProvider.id || _talkId == 0);
  }

  @override
  void setTalkChunk(TalkChunkModel model) {
    _server.emit('chunk', model.toJson());
    if (model.id != DataProvider.id) {
      onTalkChunk?.call(FoodData(Uint8List.fromList(model.chunk)));
    }
  }

  @override
  dispose() {
    _server.close();
  }
}

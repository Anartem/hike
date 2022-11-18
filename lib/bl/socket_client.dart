import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:hike_radio/bl/data_provider.dart';
import 'package:hike_radio/models/location_model.dart';
import 'package:hike_radio/models/talk_chunk_model.dart';
import 'package:hike_radio/models/talk_enable_model.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketClient extends DataProvider {
  late final Socket _client;

  SocketClient() {
    _init();
  }

  void _init() {
    _client = io(
      'http://localhost:3000',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _client.on('location', (data) {
      List<LocationModel> list = List.from(json.decode(data).map((e) => LocationModel.fromJson(e)));
      onLocation?.call(list);
    });

    _client.on('talkId', (data) {
      onTalkEnabled?.call(data == DataProvider.id || data == 0);
    });

    _client.on('chunk', (data) {
      TalkChunkModel model = TalkChunkModel.fromJson(data);
      if (model.id != DataProvider.id) {
        onTalkChunk?.call(FoodData(Uint8List.fromList(model.chunk)));
      }
    });

    _client.onDisconnect((_) => onStatus?.call(false));
    _client.onConnect((_) => onStatus?.call(true));
    _client.onConnecting((_) => onStatus?.call(false));
    _client.onConnectError((error) => onStatus?.call(false));
  }

  void start(String address) {
    _client.io.uri = 'http://$address:3000';
    _client.connect();
  }

  @override
  void stop() {
    _client.disconnect();
    _client.clearListeners();
    _client.close();
  }

  @override
  void setLocation(LocationModel model) {
    _client.emit('location', model.toJson());
  }

  @override
  void setTalk(TalkEnableModel model) {
    _client.emit('talk', model.toJson());
  }

  @override
  void setTalkChunk(TalkChunkModel model) {
    _client.emit('chunk', model.toJson());
  }

  @override
  void dispose() {
    _client.disconnect();
    _client.clearListeners();
    _client.close();
  }
}

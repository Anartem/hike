import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hike_radio/models/location_model.dart';
import 'package:hike_radio/models/talk_chunk_model.dart';
import 'package:hike_radio/models/talk_enable_model.dart';

abstract class DataProvider implements Disposable {
  static final int id = DateTime.now().millisecondsSinceEpoch;

  void Function(Iterable<LocationModel>)? onLocation;
  void Function(bool)? onTalkEnabled;
  void Function(Food)? onTalkChunk;
  void Function(bool)? onStatus;

  void setLocation(LocationModel model);

  void setTalk(TalkEnableModel model);

  void setTalkChunk(TalkChunkModel model);

  void stop();
}
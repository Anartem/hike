import 'package:hike_radio/bl/data_provider.dart';
import 'package:json_annotation/json_annotation.dart';

part '../gen/models/talk_chunk_model.gen.dart';

@JsonSerializable()
class TalkChunkModel {
  final int id;
  final List<int> chunk;

  TalkChunkModel({int? id, required this.chunk}): id = id ?? DataProvider.id;

  factory TalkChunkModel.fromJson(Map<String, dynamic> json) => _$TalkChunkModelFromJson(json);

  Map<String, dynamic> toJson() => _$TalkChunkModelToJson(this);
}
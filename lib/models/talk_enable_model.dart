import 'package:hike_radio/bl/data_provider.dart';
import 'package:json_annotation/json_annotation.dart';

part '../gen/models/talk_enable_model.gen.dart';

@JsonSerializable()
class TalkEnableModel {
  final int id;
  final bool enable;

  TalkEnableModel({int? id, required this.enable}): id = id ?? DataProvider.id;

  factory TalkEnableModel.fromJson(Map<String, dynamic> json) => _$TalkEnableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TalkEnableModelToJson(this);
}
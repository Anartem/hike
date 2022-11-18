import 'package:hike_radio/bl/data_provider.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:location/location.dart';

part '../gen/models/location_model.gen.dart';

@JsonSerializable()
class LocationModel {
  final int id;
  final double lat;
  final double lon;

  @JsonKey(ignore: true)
  bool get isOwn => id == DataProvider.id;

  LocationModel({int? id, required this.lat, required this.lon}) : id = id ?? DataProvider.id;

  LocationModel.fromData(LocationData data)
      : lat = data.latitude ?? 0.0,
        lon = data.longitude ?? 0.0,
        id = DataProvider.id;

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

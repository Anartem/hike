import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:hike_radio/models/location_model.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart';

enum LocationStatus {
  locationDisable,
  permissionGranted,
  permissionDenied,
}

class LocationUseCase implements Disposable {
  final StreamController<LocationStatus> _statusController = StreamController.broadcast();
  Stream<LocationStatus> get statusStream => _statusController.stream;

  final StreamController<LocationModel> _dataController = StreamController();
  Stream<LocationModel> get dataStream => _dataController.stream;

  StreamSubscription? _subscription;

  void checkPermission(bool request) async {
    bool enabled = await Location.instance.serviceEnabled();

    if (!enabled) {
      if (request) enabled = await Location.instance.requestService();
    }

    if (!enabled) {
      _statusController.add(LocationStatus.locationDisable);
      return;
    }

    List<Permission> list = [];
    PermissionStatus permissionStatus = await Permission.location.status;

    if (permissionStatus == PermissionStatus.denied) {
      list.add(Permission.location);
    }

    permissionStatus = await Permission.microphone.status;

    if (permissionStatus == PermissionStatus.denied) {
      list.add(Permission.microphone);
    }

    if (request && list.isNotEmpty) {
      permissionStatus = (await list.request()).values.any((e) => e != PermissionStatus.granted)
          ? PermissionStatus.denied
          : PermissionStatus.granted;
    }

    if (permissionStatus == PermissionStatus.granted) {
      _statusController.add(LocationStatus.permissionGranted);
      if (_subscription == null) {
        Location.instance.changeSettings(interval: 5000);
        _subscription = Location.instance.onLocationChanged.map(LocationModel.fromData).listen(_dataController.add);
      }
    } else {
      _statusController.add(LocationStatus.permissionDenied);
      _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  void dispose() {
    _statusController.close();
    _dataController.close();
    _subscription?.cancel();
    _subscription = null;
  }
}

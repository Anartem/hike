import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_radio/bl/use_cases/location_use_case.dart';
import 'package:hike_radio/models/location_model.dart';
import 'package:hike_radio/modules/talk/talk_bloc.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with WidgetsBindingObserver {
  late final TalkBloc _bloc = Modular.get();
  GoogleMapController? _controller;

  static const CameraPosition _default = CameraPosition(
    target: LatLng(55.7558, 37.6173),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _bloc.locationStream.where((event) => event.isNotEmpty).first.then((value) {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(value.first.lat, value.first.lon),
              zoom: 14.4746,
            ),
          ),
        );
      }).catchError((_){});
      _bloc.checkLocationPermission(true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bloc.checkLocationPermission(false);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.locationStatusStream,
      builder: (context, snapshot) {
        LocationStatus? status = snapshot.data;
        if (status == null) {
          return const SizedBox.shrink();
        }
        if (status == LocationStatus.permissionDenied) {
          return const MaterialBanner(
            padding: EdgeInsets.all(16),
            content: Text("Дайте доступ к локации и микрофону для доступа к функциям приложения"),
            actions: [
              TextButton(
                onPressed: AppSettings.openAppSettings,
                child: Text("Настройки"),
              ),
            ],
          );
        }
        if (status == LocationStatus.locationDisable) {
          return const MaterialBanner(
            padding: EdgeInsets.all(16),
            content: Text("Включите сервис локаций для трекера"),
            actions: [
              TextButton(
                onPressed: AppSettings.openLocationSettings,
                child: Text("Настройки"),
              ),
            ],
          );
        }
        return StreamBuilder<Iterable<Marker>>(
          stream: _bloc.locationStream.map((event) => event.map(_convert)),
          builder: (context, snapshot) {
            return GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _default,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              indoorViewEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: false,
              markers: snapshot.data?.toSet() ?? {},
            );
          },
        );
      },
    );
  }

  Marker _convert(LocationModel model) => Marker(
        markerId: MarkerId(model.id.toString()),
        position: LatLng(model.lat, model.lon),
        icon: BitmapDescriptor.defaultMarkerWithHue(model.isOwn ? 0 : 100),
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }
}

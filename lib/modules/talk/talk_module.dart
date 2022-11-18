import 'package:flutter_modular/flutter_modular.dart';
import 'package:hike_radio/bl/use_cases/audio_use_case.dart';
import 'package:hike_radio/bl/use_cases/location_use_case.dart';
import 'package:hike_radio/bl/use_cases/mic_use_case.dart';
import 'package:hike_radio/modules/talk/talk_bloc.dart';
import 'package:hike_radio/modules/talk/talk_page.dart';

class TalkModule extends Module {
  static const route = "/talk";

  @override
  List<Bind<Object>> get binds => [
        Bind((i) => AudioUseCase()),
        Bind((i) => LocationUseCase()),
        Bind((i) => MicUseCase()),
        Bind((i) => TalkBloc(Modular.get(), Modular.get(), Modular.get())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute("/", child: (_, __) => const TalkPage()),
      ];
}

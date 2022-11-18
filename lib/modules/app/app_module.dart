import 'package:flutter_modular/flutter_modular.dart';
import 'package:hike_radio/modules/talk/talk_module.dart';

class AppModule extends Module {
  static const route = "/";

  @override
  List<Bind<Object>> get binds => [];

  @override
  List<ModularRoute> get routes => [
    ModuleRoute(TalkModule.route, module: TalkModule()),
  ];
}
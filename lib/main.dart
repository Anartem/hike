import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hike_radio/modules/app/app_module.dart';
import 'package:hike_radio/modules/app/app_page.dart';
import 'package:hike_radio/modules/talk/talk_module.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Modular.setInitialRoute(TalkModule.route);

  runApp(
    ModularApp(
      module: AppModule(),
      child: const AppPage(),
    ),
  );
}
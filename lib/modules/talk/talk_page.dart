import 'package:flutter/material.dart';
import 'package:hike_radio/modules/talk/connect_widget.dart';
import 'package:hike_radio/modules/talk/map_widget.dart';
import 'package:hike_radio/modules/talk/talk_widget.dart';

class TalkPage extends StatelessWidget {
  const TalkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const TalkWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: const [
            ConnectWidget(),
            Expanded(child: MapWidget()),
          ],
        ),
      ),
    );
  }
}

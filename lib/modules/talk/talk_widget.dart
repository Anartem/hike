import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hike_radio/modules/talk/talk_bloc.dart';

class TalkWidget extends StatelessWidget {
  TalkBloc get _bloc => Modular.get();

  const TalkWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.statusStream,
      builder: (context, snapshot) {
        bool providerEnabled = snapshot.data ?? false;
        return StreamBuilder(
          stream: _bloc.talkStream,
          builder: (context, snapshot) {
            bool talkEnabled = providerEnabled && (snapshot.data ?? false);
            return GestureDetector(
              onTapDown: talkEnabled ? (_) => _bloc.startTalk() : null,
              onTapUp: talkEnabled ? (_) => _bloc.stopTalk() : null,
              onTapCancel: talkEnabled ? () => _bloc.stopTalk() : null,
              child: FloatingActionButton.large(
                onPressed: talkEnabled ? () {} : null,
                backgroundColor: talkEnabled
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.outline,
                child: const SizedBox(
                  child: Icon(Icons.mic),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

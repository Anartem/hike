import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hike_radio/modules/talk/talk_bloc.dart';
import 'package:app_settings/app_settings.dart';

class ConnectWidget extends StatefulWidget {
  const ConnectWidget({Key? key}) : super(key: key);

  @override
  State<ConnectWidget> createState() => _ConnectWidgetState();
}

class _ConnectWidgetState extends State<ConnectWidget> {
  late final TalkBloc _bloc = Modular.get();

  final RegExp _ipRegExp = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)');
  final TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.roleStream,
      builder: (context, snapshot) {
        Role role = _bloc.role;
        if (role == Role.undefined) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _onClient,
                  child: const Text("Присоединиться"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onServer,
                  child: const Text("Создать"),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              StreamBuilder<bool>(
                stream: _bloc.statusStream,
                builder: (context, snapshot) {
                  bool enable = snapshot.data ?? false;
                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: enable ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _bloc.stop,
                child: role == Role.server ? const Text("Прервать") : const Text("Отключиться"),
              ),
              const SizedBox(width: 16),
              if (role == Role.server) FutureBuilder(future: _bloc.getIp(), builder: (context, snapshot) {
                return Text(snapshot.data ?? "");
              },),
            ],
          ),
        );
      },
    );
  }

  void _onClient() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Подключиться к существующему вещанию"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Для общения и трекера локации вы должны находиться в одной сети. Введите IP адрес, который отображается в приложении организатора вещания."),
              TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: "192.168.1.83",
                ),
              ),
            ],
          ),
          actions: [
            ButtonBar(
              children: [
                TextButton(
                  child: const Text("Позже"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text("Подключиться"),
                  onPressed: () {
                    Navigator.pop(context);
                    RegExpMatch? match = _ipRegExp.firstMatch(_inputController.text);
                    if (match != null) {
                      _bloc.startClient(match[0]!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Неправильный IP адрес")),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void _onServer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Открыть вещание"),
          content: const Text("Для общения и трекера локации вы должны находиться в одной сети. Поднимите точку доступа и дайте доступ друзьям. Затем откройте вещание."),
          actions: [
            ButtonBar(
              children: [
                TextButton(
                  child: const Text("Точка доступа"),
                  onPressed: () => AppSettings.openHotspotSettings(),
                ),
                TextButton(
                  child: const Text("Открыть вещание"),
                  onPressed: () {
                    Navigator.pop(context);
                    _bloc.startServer();
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}

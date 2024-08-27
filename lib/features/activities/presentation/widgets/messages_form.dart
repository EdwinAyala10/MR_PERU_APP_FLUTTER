import 'dart:async';
import 'dart:developer';

import 'package:crm_app/features/activities/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessageForm extends ConsumerStatefulWidget {
  final Function(String) onSendMessage;

  final Function onTyping;

  final Function onStopTyping;

  const MessageForm({
    super.key,
    required this.onSendMessage,
    required this.onTyping,
    required this.onStopTyping,
  });

  @override
  ConsumerState<MessageForm> createState() => _ConsumerMessageFormState();
}

class _ConsumerMessageFormState extends ConsumerState<MessageForm> {
  final _textEditingController = TextEditingController();
  bool activarBusqueda = false;
  bool personaSeleccionada = false;

  Timer? _typingTimer;

  bool _isTyping = false;

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) return;

    widget.onSendMessage(_textEditingController.text);
    setState(() {
      _textEditingController.text = "";
    });
  }

  void _runTimer() {
    if (_typingTimer != null) {
      if (_typingTimer!.isActive) _typingTimer!.cancel();
    }
    _typingTimer = Timer(const Duration(milliseconds: 600), () {
      if (!_isTyping) return;
      _isTyping = false;
      widget.onStopTyping();
    });
    _isTyping = true;
    widget.onTyping();
  }

  @override
  void initState() {
    super.initState();
    // _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withAlpha(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            showModal(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                    child: TextField(
                      onChanged: (v) {
                        _runTimer();
                        if (v.contains('@')) {
                          setState(() {});
                          log(v);
                          activarBusqueda = true;
                        } else {
                          setState(() {});
                          activarBusqueda = false;
                        }
                      },
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10),
                        hintText: 'Ingresa tu mensaje....',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(FontAwesomeIcons.telegramPlane),
                  color: Theme.of(context).primaryColor,
                  iconSize: 35,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void seleccionarPersona(bool value, int index) {
    final userMarkedProvider = ref.read(usersMarkedProvider);
    final model = userMarkedProvider.allUsersMar;
    if (value) {
      _textEditingController.text += model[index].userreportName;
      personaSeleccionada = true;
    } else {
      _textEditingController.text = _textEditingController.text
          .replaceAll(model[index].userreportName, '');
    }
    setState(() {
      model[index].selected = value;
    });
  }

  void enviarNotificacion() => print('Enviado: ${_textEditingController.text}');
  Widget showModal() {
    log(activarBusqueda.toString());
    log(personaSeleccionada.toString());
    ref.read(usersMarkedProvider).getAllUsersMarked();
    if (activarBusqueda && personaSeleccionada == false) {
      return ListMarkedUsers(
        onChanged: (bool? value, int index) =>
            seleccionarPersona(value ?? false, index),
      );
    } else {
      return Container();
    }
  }
}

class ListMarkedUsers extends ConsumerWidget {
  final Function(bool?, int) onChanged;
  const ListMarkedUsers({
    super.key,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMarkedProvider = ref.watch(usersMarkedProvider);
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            final model = userMarkedProvider.allUsersMar[index];
            return ListTile(
              title: Text(model.userreportName),
              // subtitle: Text(model.userreportCodigo),
              trailing: Checkbox(
                value: model.selected,
                onChanged: (v) {
                  onChanged(v, index);
                },
              ),
              leading: CircleAvatar(
                child: Text(model.userreportName[0]),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Container();
          },
          itemCount: userMarkedProvider.allUsersMar.length,
        ),
      ),
    );
  }
}

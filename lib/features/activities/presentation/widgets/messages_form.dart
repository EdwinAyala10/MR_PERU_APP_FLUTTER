import 'dart:async';

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
  String currentMention = "";
  bool personaSeleccionada = false;
  // List<UserMarked> listSelectedUsers = [];

  Timer? _typingTimer;
  bool _isTyping = false;

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) return;

    widget.onSendMessage(
      _textEditingController.text,
    );
    setState(() {
      _textEditingController.text = "";
      activarBusqueda = false;
      currentMention = "";
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

  void _handleTextChange(String text) {
    _runTimer();

    // Encontrar la última mención en progreso
    final mentionRegex = RegExp(r'@(\w*)$');
    final match = mentionRegex.firstMatch(text);

    if (match != null) {
      // Si hay una mención en progreso
      currentMention = match.group(1)!;
      activarBusqueda = true;
      ref.read(usersMarkedProvider).getAllUsersMarked();
      setState(() {});
    } else {
      // No hay mención en progreso o se escribió un espacio
      activarBusqueda = false;
      setState(() {});
    }
  }

  void seleccionarPersona(UserMarked username) {
    // Reemplazar la mención parcial con el nombre completo del usuario seleccionado
    final mentionRegex = RegExp(r'@(\w*)$');
    _textEditingController.text = _textEditingController.text
        .replaceFirst(mentionRegex, '@${username.userreportName} ');
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: _textEditingController.text.length,
      ),
    );
    
    final currentList = ref.read(selectedUsersMarkedProvider) ?? [];
    final updatedList = [...currentList, username];
    ref.read(selectedUsersMarkedProvider.notifier).state = updatedList;

    setState(() {
      activarBusqueda = false;
      currentMention = "";
    });
    
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
                      minLines: 1,
                      maxLines: 3,
                      onChanged: _handleTextChange,
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

  Widget showModal() {
    if (activarBusqueda) {
      // Mostrar la lista de sugerencias
      return ListMarkedUsers(
        onUserSelected: (UserMarked username) {
          seleccionarPersona(username);
        },
      );
    } else {
      return Container();
    }
  }
}

class ListMarkedUsers extends ConsumerWidget {
  final Function(UserMarked) onUserSelected;

  const ListMarkedUsers({
    super.key,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMarkedProvider = ref.watch(usersMarkedProvider);
    return SizedBox(
      height: 200, // Altura ajustada para lista de sugerencias
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        child: ListView.builder(
          itemCount: userMarkedProvider.allUsersMar.length,
          itemBuilder: (context, index) {
            final model = userMarkedProvider.allUsersMar[index];
            return ListTile(
              title: Text(model.userreportName),
              onTap: () {
                onUserSelected(model);
              },
              leading: CircleAvatar(
                child: Text(model.userreportName[0]),
              ),
            );
          },
        ),
      ),
    );
  }
}

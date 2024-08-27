import 'dart:developer';

import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/domain/entities/message.dart';
import 'package:crm_app/features/activities/presentation/providers/docs_activitie_provider.dart';
import 'package:crm_app/features/auth/domain/entities/user.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definimos un ChangeNotifier para manejar el estado del chat
class ChatNotifier extends ChangeNotifier {
  IO.Socket? socket;
  List<Message> messages = [];
  String userName = '';
  User? user;
  Activity? activity;
  bool isConnected = false;
  ChatNotifier({this.user, this.activity});

  void connectToServer() {
    if (isConnected) return;
    isConnected = true; // Marca como conectado
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.onConnect((_) {
      log('Conectado al servidor');
      log('This is the name ${user?.name}');
      log('This is the name ${activity?.id}');
      socket?.emit('join', {
        'name': user?.name ?? '',
        'room': activity?.id ?? '',
      });
    });

    socket?.on('message', (data) {
      messages.add(Message.fromJson(data));
      notifyListeners();
    });

    socket?.onDisconnect((_) {
      log('Desconectado del servidor');
      isConnected = false; // Marca como desconectado
    });
  }

  void sendMessage(String message) {
    if (messages.contains('@') == true) {
      socket?.emit(
        'mentionUser',
        Message(
          content: message,
          date: DateTime.now(),
          senderName: user?.name ?? '',
          userID: user?.id ?? '',
        ).toJson(),
      );
      return;
    }

    socket?.emit(
      'sendMessage',
      Message(
        content: message,
        date: DateTime.now(),
        senderName: user?.name ?? '',
        userID: user?.id ?? '',
      ).toJson(),
    );

    // // Manejando menciones con @
    // final mentionedUsers = RegExp(r'@\w+')
    //     .allMatches(message)
    //     .map((m) => m.group(0)?.substring(1))
    //     .toList();
    // for (var user in mentionedUsers) {
    //   socket?.emit(
    //     'mentionUser',
    //     Message(
    //       user ?? '',
    //       message,
    //       DateTime.now(),
    //     ).toJson(),
    //   );
    // }
  }

  @override
  void dispose() {
    socket?.close();
    super.dispose();
  }

  void disconnect() {
    socket?.close();
    socket?.clearListeners();
  }
}

// Definimos un provider para acceder al ChatNotifier
final chatProvider = ChangeNotifierProvider<ChatNotifier>((ref) {
  final user = ref.read(authProvider).user;
  final activity = ref.watch(selectedAC);
  final notifier = ChatNotifier(user: user, activity: activity);
  ref.onDispose(() {
    notifier.disconnect();
  });
  return notifier;
});

final usersMarkedProvider = ChangeNotifierProvider<UsersMarkedNotifier>((ref) {
  final token = ref.read(authProvider).user?.token;
  final notifier = UsersMarkedNotifier(token: token);
  return notifier;
});

class UsersMarkedNotifier extends ChangeNotifier {
  List<UserMarked> _usersMarked = [];
  List<UserMarked> get allUsersMar => [..._usersMarked];
  String? token;
  UsersMarkedNotifier({this.token});

  Future<void> getAllUsersMarked() async {
    final client =
        Dio(BaseOptions(headers: {'Authorization': 'Bearer $token'}));
    ;
    const path = "http://92.118.56.131/back-mrpe-develop/public/api";
    const url = "$path/user/listar-usuarios-by-tipo";
    try {
      final response = await client.get(url);
      log(response.toString());
      if (response.data['status'] == true) {
        for (var item in response.data['data']) {
          final model = UserMarked.fromJson(item);
          _usersMarked.add(model);
          log(_usersMarked.toString());
        }
        notifyListeners();
      }
    } catch (e) {
      _usersMarked = [];
    }
  }
}

class UserMarked {
  String id;
  String userreportCodigo;
  String userreportEmail;
  String userreportName;
  String userreportType;
  String userreportAbbrt;
  bool? selected;

  UserMarked({
    required this.id,
    required this.userreportCodigo,
    required this.userreportEmail,
    required this.userreportName,
    required this.userreportType,
    required this.userreportAbbrt,
    this.selected = false,
  });

  factory UserMarked.fromJson(Map<String, dynamic> json) => UserMarked(
        id: json["ID"],
        userreportCodigo: json["USERREPORT_CODIGO"],
        userreportEmail: json["USERREPORT_EMAIL"],
        userreportName: json["USERREPORT_NAME"],
        userreportType: json["USERREPORT_TYPE"],
        userreportAbbrt: json["USERREPORT_ABBRT"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "USERREPORT_CODIGO": userreportCodigo,
        "USERREPORT_EMAIL": userreportEmail,
        "USERREPORT_NAME": userreportName,
        "USERREPORT_TYPE": userreportType,
        "USERREPORT_ABBRT": userreportAbbrt
      };
}

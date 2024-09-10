import 'dart:convert';
import 'dart:developer';

import 'package:crm_app/config/constants/environment.dart';
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
  List<MessageModel> messages = [];
  List<UsersActivitiChat> listUsersInChat = [];
  String userName = '';
  User? user;
  Activity? activity;
  bool isConnected = false;

  ChatNotifier({
    this.user,
    this.activity,
  });

  void connectToServer() {
    if (isConnected) return;
    isConnected = true; // Marca como conectado
    socket = IO.io('http://157.245.242.236:3000', <String, dynamic>{
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
      // messages.add(MessageModel.fromJson(data));
      // notifyListeners();
      final messageModel = MessageModel.fromJson(data);
      final destinosID = (data['LIST_MARKEDS'] as List)
          .map((v) => UserMarked.fromJson(v))
          .toList();
      if (data['ACCM_ID_USUARIO_REGISTRO'] == user?.code) {
        log('Entrooooo!!!!');
        registerComentActivity(
          destinoID: destinosID,
          model: messageModel,
        );
        return;
      }
      messages.add(messageModel);
      notifyListeners();
    });

    socket?.onDisconnect((_) {
      log('Desconectado del servidor');
      isConnected = false; // Marca como desconectado
    });
  }

  void sendMessage(String message, List<UserMarked> listUsersMarked) {
    if (messages.contains('@') == true) {
      socket?.emit(
        'mentionUser',
        MessageModel(
          accmComentario: message,
          accmFechaRegistro: DateTime.now(),
          accmIdUsuarioRegistro: user?.id ?? '',
        ),
      );
      return;
    }

    final payload = MessageModel(
      accmComentario: message,
      accmFechaRegistro: DateTime.now(),
      accmIdUsuarioRegistro: user?.code ?? '',
    ).toJson();

    socket?.emit(
      'sendMessage',
      jsonEncode({
        ...payload,
        "LIST_MARKEDS": listUsersMarked.map((value) => value.toJson()).toList()
      }),
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

  Future<void> registerComentActivity({
    required List<UserMarked> destinoID,
    required MessageModel model,
  }) async {
    final client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer ${user?.token}'},
      ),
    );
    final path = Environment.apiUrl;
    final url = "$path/actividad/crear-actividad-comentario";

    log(url);
    final formData = {
      "ACCM_ID_ACTIVIDAD": activity?.id,
      "ACCM_COMENTARIO": model.accmComentario,
      "ACCM_ID_USUARIO_REGISTRO": user?.code,
      "ACTIVIDAD_COMENTARIO_DESTINO": destinoID
          .map(
            (v) => {"ACCM_ID_USUARIO_DESTINO": v.userreportCodigo},
          )
          .toList()
    };
    log(formData.toString());
    final response = await client.post(url, data: formData);
    log(response.data.toString());
    if (response.data['status'] == true) {
      messages.add(model);
      notifyListeners();
    }
  }

  Future<void> listAllComents() async {
    final client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer ${user?.token}'},
      ),
    );
    final path = Environment.apiUrl;
    final url = "$path/actividad/listar-actividad-comentario";
    final formData = {'ACCM_ID_ACTIVIDAD': activity?.id};
    try {
      final response = await client.post(
        url,
        data: formData,
      );
      if (response.data['status'] == true) {
        for (var item in response.data['data']) {
          final model = MessageModel.fromJson(item);
          messages.add(model);
        }
        notifyListeners();
        return;
      }
      messages = [];
      log(response.data.toString());
      log(response.data.toString());
    } catch (e) {
      messages.clear();
    }
  }

  Future<void> listUsersComentActivity() async {
    final client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer ${user?.token}'},
      ),
    );
    final path = Environment.apiUrl;
    final url = "$path/actividad/listar-actividad-comentario-participantes";
    final formData = {'ACCM_ID_ACTIVIDAD': activity?.id};
    try {
      final response = await client.post(
        url,
        data: formData,
      );
      log(response.data.toString());
      if (response.data['status']) {
        final listUsers = response.data['data'] as List;
        final listModel = listUsers
            .map(
              (v) => UsersActivitiChat.fromJson(v),
            )
            .toList();
        listUsersInChat = [...listModel];
        notifyListeners();
        return;
      }
      listUsersInChat = [];
      notifyListeners();
    } catch (e) {
      log(e.toString());
      listUsersInChat = [];
      notifyListeners();
    }
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
  final notifier = ChatNotifier(
    user: user,
    activity: activity,
  );
  ref.onDispose(() {
    notifier.disconnect();
  });
  return notifier;
});

final selectedUsersMarkedProvider = StateProvider<List<UserMarked>?>(
  (ref) => null,
);

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
    final client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    String path = Environment.apiUrl;
    String url = "$path/user/listar-usuarios-by-tipo";
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
      log(e.toString());
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

class UsersActivitiChat {
  String? accmIdActividad;
  String? userreportCodigo;
  String? userreportEmail;
  String? userreportName;
  String? userreportAbbrt;

  UsersActivitiChat({
    this.accmIdActividad,
    this.userreportCodigo,
    this.userreportEmail,
    this.userreportName,
    this.userreportAbbrt,
  });

  factory UsersActivitiChat.fromJson(Map<String, dynamic> json) =>
      UsersActivitiChat(
        accmIdActividad: json["ACCM_ID_ACTIVIDAD"],
        userreportCodigo: json["USERREPORT_CODIGO"],
        userreportEmail: json["USERREPORT_EMAIL"],
        userreportName: json["USERREPORT_NAME"],
        userreportAbbrt: json["USERREPORT_ABBRT"],
      );

  Map<String, dynamic> toJson() => {
        "ACCM_ID_ACTIVIDAD": accmIdActividad,
        "USERREPORT_CODIGO": userreportCodigo,
        "USERREPORT_EMAIL": userreportEmail,
        "USERREPORT_NAME": userreportName,
        "USERREPORT_ABBRT": userreportAbbrt,
      };
}

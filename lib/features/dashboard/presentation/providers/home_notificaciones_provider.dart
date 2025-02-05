import 'dart:developer';

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/auth/domain/entities/user.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/dashboard/domain/entities/notifying.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listNotifyProvider =
    StateNotifierProvider<NotifyNotifier, NotifyingState>((ref) {
  final user = ref.watch(authProvider).user;
  return NotifyNotifier(
    users: user,
  );
});

class NotifyNotifier extends StateNotifier<NotifyingState> {
  User? users;
  Dio client = Dio();
  final path = Environment.apiUrl;

  NotifyNotifier({
    required this.users,
  }) : super(NotifyingState()) {
    client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer ${users?.token}'},
        baseUrl: Environment.apiUrl,
      ),
    );
    listAllNotification();
  }

  Notifying newEmptyActivity() {
    return Notifying();
  }

  Future<void> readNotification({Notifying? notifying}) async {
    try {
      final data = {
        'ACCM_ID_ACTIVIDAD': notifying?.accmIdActividad,
        'ACCM_ID_USUARIO_REGISTRO': notifying?.accmIdUsuarioRegistro,
        'ACMD_ID_ACTIVIDAD_COMENTARIO_DESTINO':
            notifying?.acmdIdActividadComentarioDestino
      };
      log(data.toString());
      final responde = await client.post(
        '/actividad/actualizar-comentario-notificaciones',
        data: data,
      );
      log(responde.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> readCounterNotification() async {
    try {
      final data = {
        'ACMD_ID_USUARIO_DESTINO': users?.code??'',
      };
      log(data.toString());
      final response = await client.post(
        '/actividad/total-comentario-notificaciones',
        data: data,
      );
      log('response counter $response');
      if(response.data['status'] == true){
        state = state.copyWith(
          counterNotification: response.data['data']['total']
        );
        
      }
      log(response.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> listAllNotification() async {
    try {
      var endPoint = "/actividad/listar-actividad-comentario-notificaciones";
      final formData = {
        'ACMD_ID_USUARIO_DESTINO': users?.code,
      };
      state = state.copyWith(isLoading: true);
      final response = await client.post(endPoint, data: formData);
      log(response.toString());
      if (response.data['status'] == true) {
        final list = (response.data['data'] as List);
        final listModel = list.map((v) => Notifying.fromJson(v)).toList();
        state = state.copyWith(isLoading: false, activity: listModel);
        return;
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      log(e.toString());
      state = state.copyWith();
    }
  }
}

class NotifyingState {
  final List<Notifying>? activity;
  final bool isLoading;
  final bool isSaving;
  final String counterNotification;

  NotifyingState({
    this.activity,
    this.isLoading = true,
    this.isSaving = false,
    this.counterNotification = '0',
  });

  NotifyingState copyWith(
          {String? id,
          List<Notifying>? activity,
          bool? isLoading,
          bool? isSaving,
          String? counterNotification}) =>
      NotifyingState(
          activity: activity ?? this.activity,
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          counterNotification: counterNotification ?? this.counterNotification);
}

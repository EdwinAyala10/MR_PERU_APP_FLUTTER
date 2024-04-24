import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final sendWhatsappProvider =
    StateNotifierProvider<SendWhatsappNotifier, SendWhatsappState>((ref) {
  //final authRepository = AuthRepositoryImpl();
  final activitiesRepository = ref.watch(activitiesRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return SendWhatsappNotifier(
    activitiesRepository: activitiesRepository,
    user: user!,
  );
});

class SendWhatsappNotifier extends StateNotifier<SendWhatsappState> {
  final ActivitiesRepository activitiesRepository;
  final User user;

  SendWhatsappNotifier({
    //required this.authRepository,
    required this.activitiesRepository,
    required this.user,
  }) : super(SendWhatsappState()) {}

  void initialSend(Contact contact, String phone) {
    state = state.copyWith(
        contact: contact, isSend: false, isViewText: true, phone: phone, message: '');
  }

  Future<bool> sendActivityMessage() async {
    try {
      var contact = state.contact;

      DateTime dateCurrent = DateTime.now();
      String hourCurrent = DateFormat('HH:mm:ss').format(dateCurrent);

      List<ContactArray> actividadesContacto = [];
      final contactArray = ContactArray(
          acntIdContacto: state.contact?.id,
          nombre: state.contact?.contactoDesc);
      actividadesContacto.add(contactArray);

      final activityLike = {
        'ACTI_NOMBRE_RESPONSABLE': user.name,
        'ACTI_ID_USUARIO_RESPONSABLE': user.code,
        'ACTI_ID_TIPO_GESTION': '05',
        "ACTI_FECHA_ACTIVIDAD":
            "${dateCurrent.year.toString().padLeft(4, '0')}-${dateCurrent.month.toString().padLeft(2, '0')}-${dateCurrent.day.toString().padLeft(2, '0')}",
        'ACTI_HORA_ACTIVIDAD': hourCurrent,
        'ACTI_RUC': state.contact?.ruc,
        'ACTI_RAZON': state.contact?.razon,
        //'ACTI_ID_OPORTUNIDAD': activityCall.actiIdOportunidad,
        'ACTI_ID_CONTACTO': contact?.id,
        'ACTI_COMENTARIO': state.message,
        'ACTI_TIEMPO_GESTION': '',
        'ACTI_ID_USUARIO_REGISTRO': user.code,
        'ACTI_NOMBRE_TIPO_GESTION': 'Whatsapp',
        'ACTIVIDADES_CONTACTO': actividadesContacto != null
            ? List<dynamic>.from(actividadesContacto.map((x) => x.toJson()))
            : [],
      };

      print('ACTIVITY ANTES WHATSAPP LIKE: ${activityLike}');

      final activityResponse =
          await activitiesRepository.createUpdateActivity(activityLike);

      print('ACTIVITY RESPONSE: ${activityResponse}');

      if (activityResponse.status) {
        print('SE ENVIO ACTIVIDAD WHATSAPP');
        state = state.copyWith(isSend: true, isViewText: false, message: '', contact: null);
        return true;
      }
    } catch (e) {
      print('NO SE ENVIO ACTIVIDAD WHATSAPP');
      return false;
    }

    return true;
  }

  void sendActivity() {
    state = state.copyWith(
      isSend: true,
    );
  }

  void onChangePrefijo(String value) {
    state = state.copyWith(
      prefijo: value,
    );
  }

  void onChangePhone(String value) {
    state = state.copyWith(
      phone: value,
    );
  }

  void onChangeMessage(String value) {
    state = state.copyWith(
      message: value,
    );
  }
}

class SendWhatsappState {
  final bool isSend;
  final bool isViewText;
  final String? prefijo;
  final String? phone;
  final String? message;
  final Contact? contact;

  SendWhatsappState(
      {this.isSend = false,
      this.isViewText = false,
      this.prefijo = '+51',
      this.phone,
      this.message = '',
      this.contact});

  SendWhatsappState copyWith({
    bool? isSend,
    bool? isViewText,
    String? prefijo,
    String? phone,
    String? message,
    Contact? contact,
  }) =>
      SendWhatsappState(
        isSend: isSend ?? this.isSend,
        isViewText: isViewText ?? this.isViewText,
        prefijo: prefijo ?? this.prefijo,
        phone: phone ?? this.phone,
        message: message ?? this.message,
        contact: contact ?? this.contact,
      );
}

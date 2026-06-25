import '../../../activities/domain/domain.dart';
import '../../../activities/presentation/providers/providers.dart';
import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../contacts/domain/domain.dart';
import '../../../opportunities/domain/domain.dart';
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
  }) : super(SendWhatsappState());

  void initialSend(Contact contact, String phone, {Opportunity? opportunity}) {
    state = SendWhatsappState(
      contact: contact,
      opportunity: opportunity,
      isSend: false,
      isViewText: true,
      phone: phone,
      message: '',
      prefijo: state.prefijo,
    );
  }

  Future<bool> sendActivityMessage() async {
    try {
      var contact = state.contact;

      DateTime dateCurrent = DateTime.now();
      String hourCurrent = DateFormat('HH:mm:ss').format(dateCurrent);
      final opportunityId = state.opportunity?.id ?? '';
      final opportunityName = state.opportunity?.oprtNombre ?? '';

      List<ContactArray> actividadesContacto = [];
      final contactArray = ContactArray(
          acntIdContacto: state.contact?.id,
          nombre: state.contact?.contactoDesc);
      actividadesContacto.add(contactArray);

      final activityLike = {
        'ACTI_NOMBRE_RESPONSABLE': user.name,
        'ACTI_ID_USUARIO_RESPONSABLE': user.code,
        'ACTI_ID_TIPO_GESTION': '05',
        'ACTI_ID_TIPO_REGISTRO': '02',
        "ACTI_FECHA_ACTIVIDAD":
            "${dateCurrent.year.toString().padLeft(4, '0')}-${dateCurrent.month.toString().padLeft(2, '0')}-${dateCurrent.day.toString().padLeft(2, '0')}",
        'ACTI_HORA_ACTIVIDAD': hourCurrent,
        'ACTI_RUC': state.contact?.ruc,
        'ACTI_RAZON': state.contact?.razon,
        'ACTI_ID_OPORTUNIDAD': opportunityId.isEmpty ? '0' : opportunityId,
        'ACTI_NOMBRE_OPORTUNIDAD': opportunityName,
        'ACTI_ID_CONTACTO': contact?.id,
        'ACTI_COMENTARIO': state.message,
        'ACTI_TIEMPO_GESTION': '',
        'ACTI_ID_USUARIO_REGISTRO': user.code,
        'ACTI_NOMBRE_TIPO_GESTION': 'Whatsapp',
        'ACTIVIDADES_CONTACTO':
            List<dynamic>.from(actividadesContacto.map((x) => x.toJson())),
      };

      final activityResponse =
          await activitiesRepository.createUpdateActivity(activityLike);

      if (activityResponse.status) {
        state = SendWhatsappState(
          isSend: true,
          isViewText: false,
          prefijo: state.prefijo,
        );
        return true;
      }
    } catch (e) {
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
  final Opportunity? opportunity;

  SendWhatsappState(
      {this.isSend = false,
      this.isViewText = false,
      this.prefijo = '+51',
      this.phone,
      this.message = '',
      this.contact,
      this.opportunity});

  SendWhatsappState copyWith({
    bool? isSend,
    bool? isViewText,
    String? prefijo,
    String? phone,
    String? message,
    Contact? contact,
    Opportunity? opportunity,
  }) =>
      SendWhatsappState(
        isSend: isSend ?? this.isSend,
        isViewText: isViewText ?? this.isViewText,
        prefijo: prefijo ?? this.prefijo,
        phone: phone ?? this.phone,
        message: message ?? this.message,
        contact: contact ?? this.contact,
        opportunity: opportunity ?? this.opportunity,
      );
}

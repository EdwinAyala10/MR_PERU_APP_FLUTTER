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
  final createUpdateCallback =
      ref.watch(activitiesProvider.notifier).createOrUpdateActivity;
  final user = ref.watch(authProvider).user;

  return SendWhatsappNotifier(
    onSubmitCallback: createUpdateCallback,
    user: user!,
  );
});

class SendWhatsappNotifier extends StateNotifier<SendWhatsappState> {
  final Future<CreateUpdateActivityResponse> Function(
      Map<dynamic, dynamic> activityLike) onSubmitCallback;
  final User user;

  SendWhatsappNotifier({
    required this.onSubmitCallback,
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
      // Si la oportunidad viene de un card agrupado por empresa, se envían
      // todos los ids de esa empresa (OPRT_ID_OPORTUNIDAD_IN); si no, el id
      // único de la oportunidad.
      final oportunidadIdsIn =
          (state.opportunity?.oprtIdOportunidadIn ?? '').trim();
      final opportunityId = oportunidadIdsIn.isNotEmpty
          ? oportunidadIdsIn
          : (state.opportunity?.id ?? '');
      final opportunityIds = opportunityId
          .split(',')
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toList();
      final opportunityName = state.opportunity?.oprtNombre ?? '';
      final baseComment = (state.message ?? '').trim();

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
        'ACTI_OPORTUNIDAD': opportunityIds.isNotEmpty
            ? opportunityIds.map((id) {
                return {
                  'ACTI_ID_OPORTUNIDAD': int.tryParse(id) ?? id,
                  'ACTI_COMENTARIO': baseComment,
                };
              }).toList()
            : [
                {
                  'ACTI_ID_OPORTUNIDAD': 0,
                  'ACTI_COMENTARIO': baseComment,
                }
              ],
        'ACTI_NOMBRE_OPORTUNIDAD': opportunityName,
        'ACTI_ID_CONTACTO': contact?.id,
        'ACTI_COMENTARIO': baseComment,
        'ACTI_NOMBRE_ARCHIVO': '',
        'ACTI_TIEMPO_GESTION': '',
        'ACTI_ID_USUARIO_REGISTRO': user.code,
        'OPT': 'INSERT',
        'ACTI_NOMBRE_TIPO_GESTION': 'Whatsapp',
        'CONTACTO_DESC': contact?.contactoDesc ?? '',
        'ACTIVIDADES_CONTACTO':
            List<dynamic>.from(actividadesContacto.map((x) => x.toJson())),
        'ACTIVIDADES_CONTACTO_ELIMINAR': [],
      };

      final activityResponse = await onSubmitCallback(activityLike);

      final normalizedMessage = activityResponse.message.toLowerCase();
      final looksSuccessful = activityResponse.response ||
          normalizedMessage.contains('correct') ||
          normalizedMessage.contains('exito') ||
          normalizedMessage.contains('exitos');

      if (looksSuccessful) {
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

    return false;
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

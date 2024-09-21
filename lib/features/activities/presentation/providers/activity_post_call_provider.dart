import 'parameters/activity_post_call_params.dart';
import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../contacts/domain/domain.dart';
import '../../../contacts/presentation/providers/contacts_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import 'package:intl/intl.dart';

final activityPostCallProvider = StateNotifierProvider.autoDispose.family<
    ActivityPostCallNotifier,
    ActivityPostCallState,
    ActivityPostCallParams>((ref, activityPostCallParams) {
  final contactsRepository = ref.watch(contactsRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return ActivityPostCallNotifier(
    contactsRepository: contactsRepository,
    user: user!,
    phone: activityPostCallParams.phone,
    contactId: activityPostCallParams.contactId,
  );
});

class ActivityPostCallNotifier extends StateNotifier<ActivityPostCallState> {
  final ContactsRepository contactsRepository;
  final User user;
  final String contactId;
  final String phone;

  ActivityPostCallNotifier({
    required this.contactsRepository,
    required this.user,
    required this.phone,
    required this.contactId,
  }) : super(ActivityPostCallState(id: 'new')) {
    loadActivityPostCall(contactId, phone);
  }

  Activity newEmptyActivity(
      String ruc, String razon, String contactoNombre, String contactoId) {
    List<ContactArray> actividadesContacto = [];

    final contactArray =
        ContactArray(acntIdContacto: contactoId, nombre: contactoNombre);

    actividadesContacto.add(contactArray);

    return Activity(
        id: 'new',
        actiComentario: '',
        actiEstadoReg: '',
        actiFechaActividad: DateTime.now(),
        actiHoraActividad: DateFormat('HH:mm:ss').format(DateTime.now()),
        actiIdContacto: '',
        actiIdOportunidad: '',
        actiIdTipoGestion: '02',
        actiIdTipoRegistro: '02',
        actiNombreTipoGestion: 'Llamada Telefónica',
        actiIdUsuarioRegistro: user.code,
        actiIdUsuarioResponsable: user.code,
        actiNombreArchivo: '',
        actiNombreOportunidad: '',
        actiRuc: ruc,
        actiRazon: razon,
        actiIdActividadIn: '',
        actiIdUsuarioActualizacion: '',
        actiNombreResponsable: user.name,
        opt: '',
        actividadesContacto: actividadesContacto,
        actividadesContactoEliminar: []);
  }

  Future<void> loadActivityPostCall(String contactId, String phone) async {
    try {
      /*if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          activity: newEmptyActivity(),
        );

        return;
      }*/

      final contact = await contactsRepository.getContactById(contactId);

      List<ContactArray> actividadesContacto = [];

      final contactArray = ContactArray(
          acntIdContacto: contact.id, nombre: contact.contactoDesc);

      actividadesContacto.add(contactArray);

      final newActivity = newEmptyActivity(
          contact.ruc, contact.razon ?? '', contact.contactoDesc, contact.id);

      state =
          state.copyWith(isLoading: false, activity: newActivity, phone: phone);
    } catch (e) {
      state = state.copyWith(isLoading: false, activity: null);
      // 404 product not found
      print(e);
    }
  }
}

class ActivityPostCallState {
  final String id;
  final Activity? activity;
  final Activity? activityCall;
  final bool? sendActivityCall;
  final Contact? contact;
  final String? phone;
  final bool isLoading;
  final bool isSaving;
  final DateTime? callStarting;
  final DateTime? callFinish;
  final String? duration;

  ActivityPostCallState({
    required this.id,
    this.activity,
    this.activityCall,
    this.sendActivityCall = false,
    this.callStarting,
    this.callFinish,
    this.duration,
    this.contact,
    this.phone,
    this.isLoading = true,
    this.isSaving = false,
  });

  ActivityPostCallState copyWith({
    String? id,
    Activity? activity,
    Activity? activityCall,
    bool? sendActivityCall,
    Contact? contact,
    String? phone,
    bool? isLoading,
    bool? isSaving,
    DateTime? callStarting,
    DateTime? callFinish,
    String? duration,
  }) =>
      ActivityPostCallState(
        id: id ?? this.id,
        activity: activity ?? this.activity,
        activityCall: activityCall ?? this.activityCall,
        sendActivityCall: sendActivityCall ?? this.sendActivityCall,
        contact: contact ?? this.contact,
        phone: phone ?? this.phone,
        callStarting: callStarting ?? this.callStarting,
        callFinish: callFinish ?? this.callFinish,
        duration: duration ?? this.duration,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

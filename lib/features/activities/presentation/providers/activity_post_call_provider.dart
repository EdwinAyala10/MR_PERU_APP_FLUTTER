import 'package:crm_app/features/activities/presentation/providers/parameters/activity_post_call_params.dart';
import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/contacts_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/activities/domain/domain.dart';
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
    loadActivityPostCall(this.contactId, this.phone);
  }

  Activity newEmptyActivity() {
    return Activity(
        id: 'new',
        actiComentario: '',
        actiEstadoReg: '',
        actiFechaActividad: DateTime.now(),
        actiHoraActividad: DateFormat('HH:mm:ss').format(DateTime.now()),
        actiIdContacto: '',
        actiIdOportunidad: '',
        actiIdTipoGestion: '',
        actiIdUsuarioRegistro: user.code,
        actiIdUsuarioResponsable: user.code,
        actiNombreArchivo: '',
        actiNombreOportunidad: '',
        actiNombreTipoGestion: '',
        actiRuc: '',
        actiIdActividadIn: '',
        actiIdUsuarioActualizacion: '',
        actiNombreResponsable: user.name,
        opt: '',
        actividadesContacto: [],
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

      print('contact IDDD: ${contactId}');
      print('contact PHONE: ${phone}');

      final contact = await contactsRepository.getContactById(contactId);

      List<ContactArray> actividadesContacto = [];

      final contactArray = ContactArray(
          acntIdContacto: contact.id, nombre: contact.contactoDesc);

      actividadesContacto.add(contactArray);

      print('EMPRESA NAME: ${contact.razon}');

      final newActivity = Activity(
          id: 'new',
          actiComentario: '',
          actiEstadoReg: '',
          actiFechaActividad: DateTime.now(),
          actiHoraActividad: DateFormat('HH:mm:ss').format(DateTime.now()),
          actiIdContacto: '',
          actiIdOportunidad: '',
          actiIdTipoGestion: '02',
          actiNombreTipoGestion: 'Llamada Telefónica',
          actiIdUsuarioRegistro: user.code,
          actiIdUsuarioResponsable: user.code,
          actiNombreArchivo: '',
          actiNombreOportunidad: '',
          actiRuc: contact.ruc,
          actiRazon: contact.razon ?? 'aaaabbbb',
          actiIdActividadIn: '',
          actiIdUsuarioActualizacion: '',
          actiNombreResponsable: user.name,
          opt: '',
          actividadesContacto: actividadesContacto,
          actividadesContactoEliminar: []);

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
  final Contact? contact;
  final String? phone;
  final bool isLoading;
  final bool isSaving;

  ActivityPostCallState({
    required this.id,
    this.activity,
    this.contact,
    this.phone,
    this.isLoading = true,
    this.isSaving = false,
  });

  ActivityPostCallState copyWith({
    String? id,
    Activity? activity,
    Contact? contact,
    String? phone,
    bool? isLoading,
    bool? isSaving,
  }) =>
      ActivityPostCallState(
        id: id ?? this.id,
        activity: activity ?? this.activity,
        contact: contact ?? this.contact,
        phone: phone ?? this.phone,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

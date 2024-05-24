import '../../domain/domain.dart';
import 'activities_repository_provider.dart';
import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../contacts/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final activityCallProvider =
    StateNotifierProvider<ActivityCallNotifier, ActivityCallState>((ref) {
  final activitiesRepository = ref.watch(activitiesRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return ActivityCallNotifier(
    activitiesRepository: activitiesRepository,
    user: user!,
  );
});

class ActivityCallNotifier extends StateNotifier<ActivityCallState> {
  final ActivitiesRepository activitiesRepository;
  final User user;

  ActivityCallNotifier({required this.activitiesRepository, required this.user})
      : super(ActivityCallState()) {
    loadNextPage();
  }

  Activity newActivityCall(String contactoId, String contactoNombre,
      String horaActividad, String duracion, String ruc, String razon) {

    List<ContactArray> actividadesContacto = [];

    final contactArray =
        ContactArray(acntIdContacto: contactoId, nombre: contactoNombre);

    actividadesContacto.add(contactArray);

    return Activity(
        id: 'new',
        actiComentario: '',
        actiEstadoReg: '',
        actiFechaActividad: DateTime.now(),
        //actiHoraActividad: DateFormat('HH:mm:ss').format(DateTime.now()),
        actiHoraActividad: horaActividad,
        actiIdContacto: contactoId,
        actiIdOportunidad: '',
        actiIdTipoGestion: '06',
        actiIdUsuarioRegistro: user.code,
        actiIdUsuarioResponsable: user.code,
        actiNombreArchivo: '',
        actiNombreOportunidad: '',
        actiNombreTipoGestion: 'Llamada Automática',
        actiRuc: ruc,
        actiRazon: razon,
        actiTiempoGestion: duracion,
        actiIdActividadIn: '',
        actiIdUsuarioActualizacion: '',
        actiNombreResponsable: user.name,
        actividadesContacto: actividadesContacto);
  }

  void onInitialCallChanged() {
    var initialDateTime = DateTime.now();
    state = state.copyWith(callStarting: initialDateTime);
  }

  
  String formatDuration(Duration duration) {
    if (duration.inSeconds < 1) {
      return '0';
    }
    String tiempoTranscurrido = '';
    if (duration.inHours > 0) {
      tiempoTranscurrido += '${duration.inHours} horas ';
      duration -= Duration(hours: duration.inHours);
    }
    if (duration.inMinutes > 0) {
      tiempoTranscurrido += '${duration.inMinutes} minutos ';
      duration -= Duration(minutes: duration.inMinutes);
    }
    if (duration.inSeconds > 0) {
      tiempoTranscurrido += '${duration.inSeconds} segundos';
    }
    return tiempoTranscurrido.trim();
  }

  void onFinishCallChanged() async {
    print('FIN LLAMADA ${state.phone}');

    var finishDateTime = DateTime.now();
    print('STATUS REAL finishDateTime: $finishDateTime');

    var durationDiff = finishDateTime.difference(state.callStarting!);

    print('STATUS REAL durationSeconds: $durationDiff');

    String duration = formatDuration(durationDiff);

    print('STATUS REAL DURATION: $duration');

    print('STATUS REAL ENVIAR ACTIVIDAD LLAMADA');

    var activityCall = newActivityCall(
        state.activity?.actividadesContacto?[0].acntIdContacto ?? '',
        state.activity?.actividadesContacto?[0].nombre ?? '',
        DateFormat('HH:mm:ss').format(DateTime.now()),
        duration,
        state.activity?.actiRuc ?? '',
        state.activity?.actiRazon ?? '');

    await createActivityCall(activityCall);

    state = state.copyWith(
        callFinish: finishDateTime,
        sendActivityCall: true,
        duration: duration,
        activityCall: activityCall);
  }

  void loadActivityCall(Activity activity) {
    /*Activity activityCall = newActivityCall(
        activity.actividadesContacto?[0].acntIdContacto ?? '',
        activity.actividadesContacto?[0].nombre ?? ''
        activity.actiRuc,
        activity.actiRazon ?? '',
        );*/

    state = state.copyWith(activity: activity, sendActivityCall: false);
  }

  Future<void> createActivityCall(Activity activity) async {
    try {
      var activityCall = activity;

      final activityLike = {
        'ACTI_NOMBRE_RESPONSABLE': activityCall.actiNombreResponsable ?? '',
        'ACTI_ID_USUARIO_RESPONSABLE': activityCall.actiIdUsuarioResponsable,
        'ACTI_ID_TIPO_GESTION': activityCall.actiIdTipoGestion,
        //'ACTI_FECHA_ACTIVIDAD': activityCall.actiFechaActividad,
        "ACTI_FECHA_ACTIVIDAD":
            "${activityCall.actiFechaActividad.year.toString().padLeft(4, '0')}-${activityCall.actiFechaActividad.month.toString().padLeft(2, '0')}-${activityCall.actiFechaActividad.day.toString().padLeft(2, '0')}",
        'ACTI_HORA_ACTIVIDAD': activityCall.actiHoraActividad,
        'ACTI_RUC': activityCall.actiRuc,
        'ACTI_RAZON': activityCall.actiRazon,
        //'ACTI_ID_OPORTUNIDAD': activityCall.actiIdOportunidad,
        'ACTI_ID_CONTACTO': activityCall.actiIdContacto,
        'ACTI_COMENTARIO': ' - ',
        'ACTI_TIEMPO_GESTION': activityCall.actiTiempoGestion,
        'ACTI_ID_USUARIO_REGISTRO': activityCall.actiIdUsuarioRegistro,
        'ACTI_NOMBRE_TIPO_GESTION': activityCall.actiNombreTipoGestion,
        'ACTIVIDADES_CONTACTO': activityCall.actividadesContacto != null
            ? List<dynamic>.from(
                activityCall.actividadesContacto!.map((x) => x.toJson()))
            : [],
      };

      final activityResponse =
          await activitiesRepository.createUpdateActivity(activityLike);

      if (activityResponse.status) {
        print('SE ENVIO ACTIVIDAD CALL');
      }
    } catch (e) {
      print('NO SE ENVIO ACTIVIDAD CALL');
    }
  }

  /*Future<CreateUpdateCompanyResponse> createOrUpdateCompany(
      Map<dynamic, dynamic> companyLike) async {
    try {
      final companyResponse =
          await companiesRepository.createUpdateCompany(companyLike);

      final message = companyResponse.message;

      if (companyResponse.status) {

        final company = companyResponse.company as Company;
        final isCompanyInList =
            state.companies.any((element) => element.ruc == company.ruc);

        if (!isCompanyInList) {
          state = state.copyWith(companies: [company, ...state.companies]);
          return CreateUpdateCompanyResponse(response: true, message: message);
        }

        state = state.copyWith(
            companies: state.companies
                .map(
                  (element) => (element.ruc == company.ruc) ? company : element,
                )
                .toList());

        return CreateUpdateCompanyResponse(response: true, message: message);
      }

      return CreateUpdateCompanyResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateCompanyResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }*/

  Future loadNextPage() async {
    /*if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final companies = await companiesRepository.getCompanies();

    if (companies.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        companies: [...state.companies, ...companies]);*/
  }
}

class ActivityCallState {
  final String? id;
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

  ActivityCallState({
    this.id,
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

  ActivityCallState copyWith({
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
      ActivityCallState(
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

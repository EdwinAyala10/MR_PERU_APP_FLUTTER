import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import 'package:intl/intl.dart';

import 'activities_repository_provider.dart';


final fromOpportunity = StateProvider<bool>((ref) => false);

final activityProvider = StateNotifierProvider.autoDispose
    .family<ActivityNotifier, ActivityState, String>((ref, id) {
  final activitiesRepository = ref.watch(activitiesRepositoryProvider);
  final user = ref.watch( authProvider ).user;

  return ActivityNotifier(
    activitiesRepository: activitiesRepository,
    user: user!,
    id: id);
});

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ActivitiesRepository activitiesRepository;
  final User user;

  ActivityNotifier({
    required this.activitiesRepository,
    required this.user,
    required String id,
  }) : super(ActivityState(id: id)) {
    loadActivity();
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
      actiIdTipoGestion: '01',
      actiIdUsuarioRegistro: user.code,
      actiIdUsuarioResponsable: user.code,
      actiNombreArchivo: '',
      actiNombreOportunidad: '',
      actiNombreTipoGestion: '',
      actiRuc: '',
      actiRazon: '',
      contactoDesc: '',
      actiIdActividadIn: '',//ACTI_ID_TIPO_REGISTRO
      actiIdTipoRegistro: '01',
      actiIdUsuarioActualizacion: '',
      actiNombreResponsable: user.name,
      opt: '',
      actividadesContacto: [],
      actividadesContactoEliminar: []
    );
  }

  Future<void> loadActivity() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          activity: newEmptyActivity(),
        );

        return;
      }

      final activity = await activitiesRepository.getActivityById(state.id);

      state = state.copyWith(isLoading: false, activity: activity);
    } catch (e) {
      state = state.copyWith(isLoading: false, activity: null);
      // 404 product not found
      print(e);
    }
  }
}

class ActivityState {
  final String id;
  final Activity? activity;
  final bool isLoading;
  final bool isSaving;

  ActivityState({
    required this.id,
    this.activity,
    this.isLoading = true,
    this.isSaving = false,
  });

  ActivityState copyWith({
    String? id,
    Activity? activity,
    bool? isLoading,
    bool? isSaving,
  }) =>
      ActivityState(
        id: id ?? this.id,
        activity: activity ?? this.activity,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

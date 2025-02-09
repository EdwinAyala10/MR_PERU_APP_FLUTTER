import 'package:crm_app/features/kpis/domain/entities/array_user.dart';

import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

import 'opportunities_repository_provider.dart';

final isFromOpportunity = StateProvider<bool>((ref) {
  return false;
});
final idCreateFromOP = StateProvider<String?>((ref) {
  return null;
});


final opportunityProvider = StateNotifierProvider.autoDispose
    .family<OpportunityNotifier, OpportunityState, String>((ref, id) {
  final opportunitiesRepository = ref.watch(opportunitiesRepositoryProvider);
  final user = ref.watch(authProvider).user;
  return OpportunityNotifier(
      opportunitiesRepository: opportunitiesRepository, user: user!, id: id);
});

class OpportunityNotifier extends StateNotifier<OpportunityState> {
  final OpportunitiesRepository opportunitiesRepository;
  final User user;

  OpportunityNotifier({
    required this.opportunitiesRepository,
    required this.user,
    required String id,
  }) : super(OpportunityState(id: id)) {
    loadOpportunity();
  }

  Opportunity newEmptyOpportunity() {
    List<ArrayUser>? arrayResponsables = [];

    //if (!user.isAdmin) {
    ArrayUser array = ArrayUser();
    array.idResponsable = user.id;
    array.cresIdUsuarioResponsable = user.code;
    array.oresIdUsuarioResponsable = user.code;
    array.userreportName = user.name;
    array.nombreResponsable = user.name;
    arrayResponsables.add(array);
    //}

    return Opportunity(
      id: 'new',
      oprtEntorno: 'MR PERU',
      oprtIdEstadoOportunidad: '',
      oprtNombre: '',
      oprtComentario: '',
      oprtFechaPrevistaVenta: DateTime.now(),
      oprtIdOportunidadIn: '',
      oprtIdUsuarioRegistro: user.code,
      oprtIdValor: '01',
      oprtValor: '0',
      oprtIdContacto: '',
      oprtNobbreEstadoOportunidad: '',
      oprtNombreValor: '',
      oprtProbabilidad: '0',
      oprtLocalCodigo: '',
      oprtLocalNombre: '',
      oprtRuc: '',
      //oprtRucIntermediario01: '',
      oprtRucIntermediario02: '',
      opt: '',
      arrayresponsables: arrayResponsables,
      arrayresponsablesEliminar: [],
    );
  }

  Future<void> loadOpportunity() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          opportunity: newEmptyOpportunity(),
        );

        return;
      }

      final opportunity =
          await opportunitiesRepository.getOpportunityById(state.id);

      state = state.copyWith(isLoading: false, opportunity: opportunity);
    } catch (e) {
      state = state.copyWith(isLoading: false, opportunity: null);
    }
  }
}

class OpportunityState {
  final String id;
  final Opportunity? opportunity;
  final bool isLoading;
  final bool isSaving;

  OpportunityState({
    required this.id,
    this.opportunity,
    this.isLoading = true,
    this.isSaving = false,
  });

  OpportunityState copyWith({
    String? id,
    Opportunity? opportunity,
    bool? isLoading,
    bool? isSaving,
  }) =>
      OpportunityState(
        id: id ?? this.id,
        opportunity: opportunity ?? this.opportunity,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

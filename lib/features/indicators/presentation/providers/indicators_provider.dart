import 'package:crm_app/features/indicators/domain/entities/send_indicators_response.dart';
import 'package:crm_app/features/indicators/domain/repositories/indicators_repository.dart';
import 'package:crm_app/features/indicators/presentation/providers/indicators_repository_provider.dart';
import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';


final indicatorsProvider =
    StateNotifierProvider<IndicatorsNotifier, IndicatorsState>((ref) {
  final indicatorsRepository = ref.watch(indicatorsRepositoryProvider);
  return IndicatorsNotifier(indicatorsRepository: indicatorsRepository);
});

class IndicatorsNotifier extends StateNotifier<IndicatorsState> {
  final IndicatorsRepository indicatorsRepository;

  IndicatorsNotifier({required this.indicatorsRepository}) : super(IndicatorsState()) {
    //loadNextPage();
  }

  void onDateInitialChanged(DateTime fecha) {
    state = state.copyWith(dateInitial: fecha);
  }

  void onDateEndChanged(DateTime fecha) {
    state = state.copyWith(dateEnd: fecha);
  }

  void onUsersChanged(UserMaster usuario) {
    bool objExist = state.arrayresponsables!.any(
        (objeto) => objeto.id == usuario.id && objeto.name == usuario.name);

    if (!objExist) {
      ArrayUser array = ArrayUser();
      array.idResponsable = usuario.id;
      array.cresIdUsuarioResponsable = usuario.code;
      array.userreportName = usuario.name;
      array.nombreResponsable = usuario.name;
      array.oresIdUsuarioResponsable = usuario.code;

      List<ArrayUser> arrayUsuarios = [...state.arrayresponsables ?? [], array];

      state = state.copyWith(arrayresponsables: arrayUsuarios);
    } else {
      state = state;
    }
  }

  void onDeleteUserChanged(ArrayUser item) {
    List<ArrayUser> arrayUsuarios = state.arrayresponsables!
        .where((user) => user.oresIdOportunidadResp != item.oresIdOportunidadResp)
        .toList();
    state = state.copyWith(
        arrayresponsables: arrayUsuarios);
  }


  Future<SendIndicatorsResponse> sendIndicators(
      Map<dynamic, dynamic> params) async {
    try {
      final indicatorsResponse = await indicatorsRepository.sendIndicators(params);

      final message = indicatorsResponse.message;

      if (indicatorsResponse.status) {
        return SendIndicatorsResponse(response: true, message: message);
      }

      return SendIndicatorsResponse(response: false, message: message);
    } catch (e) {
      return SendIndicatorsResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

}

class IndicatorsState {
  final DateTime? dateInitial;
  final DateTime? dateEnd;
  final List<ArrayUser>? arrayresponsables;
  final bool isSend;

  IndicatorsState(
      {this.dateInitial, this.dateEnd, this.arrayresponsables = const [], this.isSend = false});

  IndicatorsState copyWith({
    DateTime? dateInitial,
    DateTime? dateEnd,
    List<ArrayUser>? arrayresponsables,
    bool? isSend,
  }) =>
      IndicatorsState(
        dateInitial: dateInitial ?? this.dateInitial,
        dateEnd: dateEnd ?? this.dateEnd,
        arrayresponsables: arrayresponsables ?? this.arrayresponsables,
        isSend: isSend ?? this.isSend,
      );
}

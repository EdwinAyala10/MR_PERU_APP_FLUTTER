import '../../domain/entities/send_indicators_response.dart';
import '../../domain/repositories/indicators_repository.dart';
import 'indicators_repository_provider.dart';
import '../../../kpis/domain/entities/array_user.dart';
import '../../../users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final indicatorsProvider =
    StateNotifierProvider<IndicatorsNotifier, IndicatorsState>((ref) {
  final indicatorsRepository = ref.watch(indicatorsRepositoryProvider);
  return IndicatorsNotifier(indicatorsRepository: indicatorsRepository);
});

class IndicatorsNotifier extends StateNotifier<IndicatorsState> {
  final IndicatorsRepository indicatorsRepository;

  IndicatorsNotifier({required this.indicatorsRepository})
      : super(IndicatorsState()) {
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
        .where(
            (user) => user.oresIdOportunidadResp != item.oresIdOportunidadResp)
        .toList();
    state = state.copyWith(arrayresponsables: arrayUsuarios);
  }

  void resetForm() {
    state = state.copyWith(
        dateEnd: DateTime.now(),
        dateInitial: DateTime.now(),
        arrayresponsables: []);
  }

  Future<SendIndicatorsResponse> onFormSubmit() async {
    state = state.copyWith(isLoading: true);

    final params = {
      "DATE_INI":
          "${state.dateInitial?.year.toString().padLeft(4, '0')}-${state.dateInitial?.month.toString().padLeft(2, '0')}-${state.dateInitial?.day.toString().padLeft(2, '0')}",
      "DATE_FIN":
          "${state.dateEnd?.year.toString().padLeft(4, '0')}-${state.dateEnd?.month.toString().padLeft(2, '0')}-${state.dateEnd?.day.toString().padLeft(2, '0')}",
      'USERS': state.arrayresponsables != null
          ? List<dynamic>.from(state.arrayresponsables!.map((x) => x.toJson()))
          : [],
    };
    

    try {
      state = state.copyWith(isLoading: false);
      return await sendIndicators(params);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return SendIndicatorsResponse(response: false, message: '');
    }
  }

  Future<SendIndicatorsResponse> sendIndicators(
      Map<dynamic, dynamic> params) async {
    try {
      final indicatorsResponse =
          await indicatorsRepository.sendIndicators(params);

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
  final bool isLoading;

  IndicatorsState(
      {this.dateInitial,
      this.dateEnd,
      this.arrayresponsables = const [],
      this.isSend = false,
      this.isLoading = false});

  IndicatorsState copyWith({
    DateTime? dateInitial,
    DateTime? dateEnd,
    List<ArrayUser>? arrayresponsables,
    bool? isSend,
    bool? isLoading,
  }) =>
      IndicatorsState(
        dateInitial: dateInitial ?? this.dateInitial,
        dateEnd: dateEnd ?? this.dateEnd,
        arrayresponsables: arrayresponsables ?? this.arrayresponsables,
        isSend: isSend ?? this.isSend,
        isLoading: isLoading ?? this.isLoading,
      );
}

import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/check_in_by_ruc_local.dart';
import '../../domain/entities/check_in_by_ruc_local_response.dart';
import 'providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

final companyCheckInProvider = StateNotifierProvider.autoDispose
    .family<CompanyCheckInNotifier, CompanyCheckInState, String>((ref, id) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  final user = ref.watch(authProvider).user;
  List<String> ids = id.split("*");
  String idCheck = ids[0];
  String ruc = ids[1];
  String idLocal = ids[2];
  String nombreLocal = ids[3];
  String latLocal = ids[4];
  String lngLocal = ids[5];
  final company = ref.read(companyProvider(ruc).notifier).state.company;

  return CompanyCheckInNotifier(
    companiesRepository: companiesRepository,
    id: idCheck,
    ruc: company!.ruc,
    nameEmpresa: company.razon,
    idLocal: idLocal,
    nombreLocal: nombreLocal,
    latLocal: latLocal,
    lngLocal: lngLocal,
    user: user!,
  );
});

class CompanyCheckInNotifier extends StateNotifier<CompanyCheckInState> {
  final CompaniesRepository companiesRepository;
  final User user;
  final String ruc;
  final String nameEmpresa;
  final String idLocal;
  final String nombreLocal;
  final String latLocal;
  final String lngLocal;

  CompanyCheckInNotifier({
    required this.companiesRepository,
    required this.user,
    required this.ruc,
    required this.nameEmpresa,
    required this.idLocal,
    required this.nombreLocal,
    required this.latLocal,
    required this.lngLocal,
    required String id,
  }) : super(CompanyCheckInState(id: id)) {
    loadCompanyCheckIn(id);
  }

  CompanyCheckIn newEmptyCompanyCheckIn(String idCheck) {
    String isIdLocal = idLocal == '-' ? '' : idLocal;
    String isNombreLocal = nombreLocal == '-' ? '' : nombreLocal;

    return CompanyCheckIn(
      cchkIdClientesCheck: 'new',
      cchkIdComentario: '',
      cchkIdContacto: '',
      cchkIdEstadoCheck: idCheck,
      cchkIdOportunidad: '',
      cchkIdUsuarioResponsable: user.code,
      cchkNombreUsuarioResponsable: user.name,
      cchkRuc: ruc,
      cchkRazon: nameEmpresa,
      cchkCoordenadaLatitud: latLocal,
      cchkCoordenadaLongitud: lngLocal,
      cchkDireccionMapa: '',
      cchkIdUsuarioRegistro: user.code,
      cchkUbigeo: '',
      cchkLocalCodigo: isIdLocal,
      cchkLocalNombre: isNombreLocal,
      cchkNombreOportunidad: '',
      cchkNombreContacto: '',
      cchkVisitaFrioCaliente: ''
    );
  }

  Future<void> loadCompanyCheckIn(String idCheck) async {
    try {
      CompanyCheckIn companyCheckInNew = newEmptyCompanyCheckIn(idCheck);

      if (idCheck == '06') {
        // CHECKIN
        CheckInByRucLocalResponse checkInByRucLocalResponse =
            await companiesRepository.getCheckInByRucLocal(ruc, user.code);

        if (checkInByRucLocalResponse.checkInByRucLocal != null) {
          CheckInByRucLocal checkInByRucLocal =
              checkInByRucLocalResponse.checkInByRucLocal!;

          companyCheckInNew = CompanyCheckIn(
              cchkIdClientesCheck: 'new',
              cchkRuc: checkInByRucLocal.ruc,
              cchkIdOportunidad: checkInByRucLocal.idOportunidad,
              cchkNombreOportunidad: checkInByRucLocal.oprtNombre,
              cchkIdContacto: checkInByRucLocal.idContacto,
              cchkNombreContacto: checkInByRucLocal.contactoDesc,
              cchkIdEstadoCheck: idCheck,
              cchkIdComentario: '',
              cchkIdUsuarioResponsable: user.code,
              cchkNombreUsuarioResponsable: user.name,
              cchkLocalCodigo: checkInByRucLocal.cchkLocalCodigo,
              cchkLocalNombre: '${checkInByRucLocal.localNombre} ${checkInByRucLocal.localDireccion}',
              cchkCoordenadaLatitud: checkInByRucLocal.coordenadasLatitud,
              cchkCoordenadaLongitud: checkInByRucLocal.coordenadasLongitud,
              cchkRazon: checkInByRucLocal.razon,
              cchkDireccionMapa: checkInByRucLocal.localDireccion,
              );
        }
      }

      //if (state.id == 'new') {
      state = state.copyWith(
        isLoading: false,
        companyCheckIn: companyCheckInNew,
      );
      //return;
      //}

      //final company = await companiesRepository.getCompanyById(state.rucId);

      //state = state.copyWith(isLoading: false, companyCheckIn: company);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class CompanyCheckInState {
  final String id;
  final CompanyCheckIn? companyCheckIn;
  final bool isLoading;
  final bool isSaving;

  CompanyCheckInState({
    required this.id,
    this.companyCheckIn,
    this.isLoading = true,
    this.isSaving = false,
  });

  CompanyCheckInState copyWith({
    String? id,
    CompanyCheckIn? companyCheckIn,
    bool? isLoading,
    bool? isSaving,
  }) =>
      CompanyCheckInState(
        id: id ?? this.id,
        companyCheckIn: companyCheckIn ?? this.companyCheckIn,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

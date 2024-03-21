import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

final companyCheckInProvider = StateNotifierProvider.autoDispose
    .family<CompanyCheckInNotifier, CompanyCheckInState, String>((ref, id) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  final user = ref.watch(authProvider).user;
  List<String> ids = id.split("*");
  String idCheck = ids[0];
  String ruc = ids[1];
  final company = ref.read(companyProvider(ruc).notifier).state.company;

  return CompanyCheckInNotifier(
    companiesRepository: companiesRepository,
    id: idCheck,
    ruc: company!.ruc,
    nameEmpresa: company.razon,
    user: user!,
  );
});

class CompanyCheckInNotifier extends StateNotifier<CompanyCheckInState> {
  final CompaniesRepository companiesRepository;
  final User user;
  final String ruc;
  final String nameEmpresa;

  CompanyCheckInNotifier({
    required this.companiesRepository,
    required this.user,
    required this.ruc,
    required this.nameEmpresa,
    required String id,
  }) : super(CompanyCheckInState(id: id)) {
    loadCompanyCheckIn(id);
  }

  CompanyCheckIn newEmptyCompanyCheckIn(String idCheck) {
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
      cchkCoordenadaLatitud: '',
      cchkCoordenadaLongitud: '',
      cchkDireccionMapa: '',
      cchkIdUsuarioRegistro: user.code,
      cchkUbigeo: '',
      cchkNombreOportunidad: '',
      cchkNombreContacto: '',
    );
  }

  Future<void> loadCompanyCheckIn(String idCheck) async {
    try {
      //if (state.id == 'new') {
      state = state.copyWith(
        isLoading: false,
        companyCheckIn: newEmptyCompanyCheckIn(idCheck),
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

import 'companies_repository_provider.dart';

final companyProvider = StateNotifierProvider.autoDispose
    .family<CompanyNotifier, CompanyState, String>((ref, rucId) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);

  return CompanyNotifier(
      companiesRepository: companiesRepository, rucId: rucId);
});

class CompanyNotifier extends StateNotifier<CompanyState> {
  final CompaniesRepository companiesRepository;

  CompanyNotifier({
    required this.companiesRepository,
    required String rucId,
  }) : super(CompanyState(rucId: rucId)) {
    loadCompany();
  }

  Company newEmptyCompany() {
    return Company(
      rucId: 'new',
      razon: '',
      ruc: '',
      direccion: '',
      telefono: '',
      observaciones: '',
      departamento: '',
      provincia: '',
      distrito: '',
      seguimientoComentario: '',
      website: '',
      calificacion: 'A',
      usuarioRegistro: '',
      visibleTodos: '1',
      email: '',
      codigoPostal: '',
      tipocliente: '04',
      estado: 'A',
      localNombre: '',
      usuarioActualizacion: '',
      coordenadasGeo: '',
      coordenadasLatitud: '',
      coordenadasLongitud: '',
      enviarNotificacion: '',
      localDepartamento: '',
      localDepartamentoDesc: '',
      localDireccion: '',
      localDistrito: '',
      localDistritoDesc: '',
      localProvinciaDesc: '',
      localTipo: '',
      orden: '',
      ubigeoCodigo: '',
      voltajeTension: '',
      arrayresponsables: [],
    );
  }

  Future<void> loadCompany() async {
    try {
      if (state.rucId == 'new') {
        state = state.copyWith(
          isLoading: false,
          company: newEmptyCompany(),
        );
        return;
      }

      final company = await companiesRepository.getCompanyById(state.rucId);
      company.rucId = company.ruc;

      state = state.copyWith(isLoading: false, company: company);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class CompanyState {
  final String rucId;
  final Company? company;
  final bool isLoading;
  final bool isSaving;

  CompanyState({
    required this.rucId,
    this.company,
    this.isLoading = true,
    this.isSaving = false,
  });

  CompanyState copyWith({
    String? rucId,
    Company? company,
    bool? isLoading,
    bool? isSaving,
  }) =>
      CompanyState(
        rucId: rucId ?? this.rucId,
        company: company ?? this.company,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

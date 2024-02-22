import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

import 'companies_repository_provider.dart';


final companyProvider = StateNotifierProvider.autoDispose.family<CompanyNotifier, CompanyState, String>(
  (ref, ruc ) {
    
    final companiesRepository = ref.watch(companiesRepositoryProvider);
  
    return CompanyNotifier(
      companiesRepository: companiesRepository, 
      ruc: ruc
    );
});



class CompanyNotifier extends StateNotifier<CompanyState> {

  final CompaniesRepository companiesRepository;


  CompanyNotifier({
    required this.companiesRepository,
    required String ruc,
  }): super(CompanyState(ruc: ruc )) {
    loadCompany();
  }

  Company newEmptyCompany() {
    return Company(
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
      calificacion: '',
      usuarioRegistro: '',
      visibleTodos: '1',
      email: '',
      codigoPostal: '',
      tipocliente: '',
      estado: '',
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
    );
  }


  Future<void> loadCompany() async {

    try {

      if ( state.ruc == 'new' ) {
        state = state.copyWith(
          isLoading: false,
          company: newEmptyCompany(),
        );  
        return;
      }

      final company = await companiesRepository.getCompanyById(state.ruc);

      state = state.copyWith(
        isLoading: false,
        company: company
      );

    } catch (e) {
      // 404 product not found
      print(e);
    }

  }

}




class CompanyState {

  final String ruc;
  final Company? company;
  final bool isLoading;
  final bool isSaving;

  CompanyState({
    required this.ruc, 
    this.company, 
    this.isLoading = true, 
    this.isSaving = false,
  });

  CompanyState copyWith({
    String? ruc,
    Company? company,
    bool? isLoading,
    bool? isSaving,
  }) => CompanyState(
    ruc: ruc ?? this.ruc,
    company: company ?? this.company,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
  );
  
}


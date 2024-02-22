import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

import 'companies_repository_provider.dart';


final companyProvider = StateNotifierProvider.autoDispose.family<CompanyNotifier, CompanyState, String>(
  (ref, id ) {
    
    final companiesRepository = ref.watch(companiesRepositoryProvider);
  
    return CompanyNotifier(
      companiesRepository: companiesRepository, 
      id: id
    );
});



class CompanyNotifier extends StateNotifier<CompanyState> {

  final CompaniesRepository companiesRepository;


  CompanyNotifier({
    required this.companiesRepository,
    required String id,
  }): super(CompanyState(id: id )) {
    loadCompany();
  }

  Company newEmptyCompany() {
    return Company(
      id: 'new',
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
    );
  }


  Future<void> loadCompany() async {

    print('state ID: ${state.id}');

    try {

      if ( state.id == 'new' ) {
        state = state.copyWith(
          isLoading: false,
          company: newEmptyCompany(),
        );  
        return;
      }

      final company = await companiesRepository.getCompanyById(state.id);

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

  final String id;
  final Company? company;
  final bool isLoading;
  final bool isSaving;

  CompanyState({
    required this.id, 
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
    id: ruc ?? this.id,
    company: company ?? this.company,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
  );
  
}


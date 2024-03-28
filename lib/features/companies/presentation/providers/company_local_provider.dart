import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

final companyLocalProvider = StateNotifierProvider.autoDispose
    .family<CompanyLocalNotifier, CompanyLocalState, String>((ref, id) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  final user = ref.watch(authProvider).user;
  List<String> ids = id.split("*");
  String idLocal = ids[0];
  String ruc = ids[1];
  final company = ref.read(companyProvider(ruc).notifier).state.company;

  return CompanyLocalNotifier(
    companiesRepository: companiesRepository,
    id: idLocal,
    ruc: company!.ruc,
    nameEmpresa: company.razon,
    user: user!,
  );
});

class CompanyLocalNotifier extends StateNotifier<CompanyLocalState> {
  final CompaniesRepository companiesRepository;
  final User user;
  final String ruc;
  final String nameEmpresa;

  CompanyLocalNotifier({
    required this.companiesRepository,
    required this.user,
    required this.ruc,
    required this.nameEmpresa,
    required String id,
  }) : super(CompanyLocalState(id: id)) {
    loadCompanyLocal();
  }

  CompanyLocal newEmptyCompanyLocal() {
    return CompanyLocal(
      id: 'new',
      localNombre: '',
      ruc: ruc,
      razon: nameEmpresa,
      coordenadasGeo: '',
      coordenadasLatitud: '',
      coordenadasLongitud: '',
      departamento: '',
      distrito: '',
      localDepartamento: '',
      localDepartamentoDesc: '',
      localDireccion: '',
      localDistrito: '',
      localDistritoDesc: '',
      localProvincia: '',
      localProvinciaDesc: '',
      localTipo: '1',
      provincia: '',
      ubigeoCodigo: '',
    );
  }

  Future<void> loadCompanyLocal() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          companyLocal: newEmptyCompanyLocal(),
        );
        return;
      }

      //final company = await companiesRepository.getCompanyById(state.rucId);

      //state = state.copyWith(isLoading: false, companyCheckIn: company);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }

}

class CompanyLocalState {
  final String id;
  final CompanyLocal? companyLocal;
  final bool isLoading;
  final bool isSaving;

  CompanyLocalState({
    required this.id,
    this.companyLocal,
    this.isLoading = true,
    this.isSaving = false,
  });

  CompanyLocalState copyWith({
    String? id,
    CompanyLocal? companyLocal,
    bool? isLoading,
    bool? isSaving,
  }) =>
      CompanyLocalState(
        id: id ?? this.id,
        companyLocal: companyLocal ?? this.companyLocal,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

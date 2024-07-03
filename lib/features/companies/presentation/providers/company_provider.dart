import '../../../activities/domain/domain.dart';
import '../../../activities/presentation/providers/activities_repository_provider.dart';
import '../../../agenda/domain/domain.dart';
import '../../../agenda/presentation/providers/events_repository_provider.dart';
import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/create_update_company_local_response.dart';
import '../../../contacts/domain/domain.dart';
import '../../../contacts/presentation/providers/contacts_repository_provider.dart';
import '../../../opportunities/domain/domain.dart';
import '../../../opportunities/presentation/providers/opportunities_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

import 'companies_repository_provider.dart';

final companyProvider = StateNotifierProvider.autoDispose
    .family<CompanyNotifier, CompanyState, String>((ref, rucId) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  final contactsRepository = ref.watch(contactsRepositoryProvider);
  final opportunitiesRepository = ref.watch(opportunitiesRepositoryProvider);
  final activitiesRepository = ref.watch(activitiesRepositoryProvider);
  final eventsRepository = ref.watch(eventsRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return CompanyNotifier(
      companiesRepository: companiesRepository,
      contactsRepository: contactsRepository,
      opportunitiesRepository: opportunitiesRepository,
      activitiesRepository: activitiesRepository,
      eventsRepository: eventsRepository,
      user: user!,
      rucId: rucId);
});

class CompanyNotifier extends StateNotifier<CompanyState> {
  final CompaniesRepository companiesRepository;
  final ContactsRepository contactsRepository;
  final OpportunitiesRepository opportunitiesRepository;
  final ActivitiesRepository activitiesRepository;
  final EventsRepository eventsRepository;
  final User user;

  CompanyNotifier({
    required this.companiesRepository,
    required this.contactsRepository,
    required this.opportunitiesRepository,
    required this.activitiesRepository,
    required this.eventsRepository,
    required this.user,
    required String rucId,
  }) : super(CompanyState(rucId: rucId)) {
    loadCompany();
  }

  Company newEmptyCompany() {
    return Company(
      rucId: 'new',
      razon: '',
      ruc: '',
      idRubro: '',
      direccion: '',
      telefono: '',
      observaciones: '',
      departamento: '',
      provincia: '',
      distrito: '',
      clienteCoordenadasGeo: '',
      clienteCoordenadasLatitud: '',
      clienteCoordenadasLongitud: '',
      seguimientoComentario: '',
      localCodigoPostal: '',
      website: '',
      calificacion: '',
      usuarioRegistro: user.code,
      idUsuarioRegistro: user.code,
      idUsuarioActualizacion: user.code,
      visibleTodos: '1',
      email: '',
      codigoPostal: '',
      tipocliente: '',
      estado: '',
      localNombre: '',
      usuarioActualizacion: user.code,
      coordenadasGeo: '',
      coordenadasLatitud: '',
      coordenadasLongitud: '',
      enviarNotificacion: '',
      localDepartamento: '',
      localDepartamentoDesc: '',
      localDireccion: '',
      localDistrito: '',
      clienteNombreEstado: 'ACTIVO',
      localDistritoDesc: '',
      localProvinciaDesc: '',
      localTipo: '2',
      localCantidad: '1',
      orden: '',
      clienteNombreTipo: 'Cliente',
      cchkIdEstadoCheck: '',
      ubigeoCodigo: '',
      voltajeTension: '',
      userreporteName: user.name,
      arrayresponsables: [],
      arrayresponsablesEliminar: [],
    );
  }

  Future<void> updateCheckState(String idCheck) async {
    Company? companyNew = state.company;

    //companyNew?.cchkIdEstadoCheck = idCheck == '01' ? '06' : '01';
    companyNew?.cchkIdEstadoCheck = idCheck;

    state = state.copyWith(company: companyNew);
  }

  Future<void> loadSecundaryDetails() async {

    final contacts = await contactsRepository.getContacts(ruc: state.company!.ruc, search: '', limit: 100, offset: 0);
    final opportunities =
        await opportunitiesRepository.getOpportunities(ruc:state.company!.ruc, search: '', limit: 100, offset: 0);
    final activities = await activitiesRepository.getActivitiesByRuc(state.company!.ruc);
    final events = await eventsRepository.getEventsListByRuc(state.company!.ruc);
    final companyLocales =
        await companiesRepository.getCompanyLocales(state.company!.ruc);

    state = state.copyWith(
      contacts: contacts,
      opportunities: opportunities,
      activities: activities,
      events: events,
      companyLocales: companyLocales,
    );
  }

  Future<void> isLoading() async {
    state = state.copyWith(
      isSaving: true
    );
  }

  Future<void> isNotLoading() async {
    state = state.copyWith(
      isSaving: false
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

      final company = await companiesRepository.getCompanyById(state.rucId, user.code);
      company.rucId = company.ruc;

      /*final contacts = await contactsRepository.getContacts(ruc: company.ruc, search: '', limit: 100, offset: 0);
      final opportunities =
          await opportunitiesRepository.getOpportunities(ruc:company.ruc, search: '', limit: 100, offset: 0);
      final activities = await activitiesRepository.getActivitiesByRuc(company.ruc);
      final events = await eventsRepository.getEventsListByRuc(company.ruc);
      final companyLocales =
          await companiesRepository.getCompanyLocales(company.ruc);*/

      state = state.copyWith(
        isLoading: false,
        company: company,
        /*contacts: contacts,
        opportunities: opportunities,
        activities: activities,
        events: events,
        companyLocales: companyLocales,*/
      );
    } catch (e) {
      // 404 product not found
      state = state.copyWith(isLoading: false, company: null);
      print(e);
    }
  }

  Future<void> loadContacts(String ruc) async {
    try {
      final contacts = await contactsRepository.getContacts(ruc: ruc, search: '', limit: 100, offset: 0);
      state = state.copyWith(contacts: contacts);
    } catch (e) {
      state = state.copyWith(contacts: []);
    }
  }

  Future<CreateUpdateCompanyLocalResponse> createOrUpdateCompanyLocal(
      Map<dynamic, dynamic> companyLocalLike) async {
    try {
      final companyLocalResponse =
          await companiesRepository.createUpdateCompanyLocal(companyLocalLike);

      final message = companyLocalResponse.message;

      if (companyLocalResponse.status) {
        //final companyCheckIn = companyCheckInResponse.companyCheckIn as CompanyCheckIn;
        final companyLocal = companyLocalResponse.companyLocal as CompanyLocal;
        final isCompanyLocalInList = state.companyLocales
            .any((element) => element.ruc == companyLocal.id);

        if (!isCompanyLocalInList) {
          state = state.copyWith(
              companyLocales: [companyLocal, ...state.companyLocales]);
          return CreateUpdateCompanyLocalResponse(
              response: true, message: message);
        }

        state = state.copyWith(
            companyLocales: state.companyLocales
                .map(
                  (element) =>
                      (element.id == companyLocal.id) ? companyLocal : element,
                )
                .toList());

        return CreateUpdateCompanyLocalResponse(
            response: true, message: message);
      }

      return CreateUpdateCompanyLocalResponse(
          response: false, message: message);
    } catch (e) {
      return CreateUpdateCompanyLocalResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }
}

class CompanyState {
  final String rucId;
  final Company? company;
  final List<Contact> contacts;
  final List<Opportunity> opportunities;
  final List<Activity> activities;
  final List<Event> events;
  final List<CompanyLocal> companyLocales;
  final bool isLoading;
  final bool isSaving;

  CompanyState({
    required this.rucId,
    this.company,
    this.contacts = const [],
    this.opportunities = const [],
    this.activities = const [],
    this.events = const [],
    this.companyLocales = const [],
    this.isLoading = true,
    this.isSaving = false,
  });

  CompanyState copyWith({
    String? rucId,
    Company? company,
    List<Contact>? contacts,
    List<Opportunity>? opportunities,
    List<Activity>? activities,
    List<Event>? events,
    List<CompanyLocal>? companyLocales,
    bool? isLoading,
    bool? isSaving,
  }) =>
      CompanyState(
        rucId: rucId ?? this.rucId,
        company: company ?? this.company,
        contacts: contacts ?? this.contacts,
        opportunities: opportunities ?? this.opportunities,
        activities: activities ?? this.activities,
        events: events ?? this.events,
        companyLocales: companyLocales ?? this.companyLocales,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

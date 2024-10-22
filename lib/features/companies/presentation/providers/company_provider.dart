import 'dart:developer';

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
import 'package:dio/dio.dart';

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



final stateRucProvider = StateProvider((ref) => '');

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

    List<ArrayUser>? arrayResponsables = [];

    //if (!user.isAdmin) {
      ArrayUser array = ArrayUser();
      array.idResponsable = user.id;
      array.cresIdUsuarioResponsable = user.code;
      array.userreportName = user.name;
      array.nombreResponsable = user.name;
      arrayResponsables.add(array);
    //}

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
      razonComercial: '',
      userreporteName: user.name,
      arrayresponsables: arrayResponsables,
      arrayresponsablesEliminar: [],
    );
  }



  Future<Map<String,dynamic>> removeClient(String ruc)async{
    final client = Dio(
    BaseOptions(
      headers: {'Authorization': 'Bearer ${user.token}'},
    ),
    );
    final path = Environment.apiUrl;
    final url = "$path/cliente/baja-cliente";
    final formData = {'RUC': ruc}; 
    try {
      final response = await client.post(url,data: formData);
      log('message $response');
      if(response.data['status']){
        return {
          "status": true,
          "message": response.data['message'] 
        };
      }
      return {
      "status": false,
      "message": response.data['message'] 
      };
    } catch (e) {
        log(e.toString());
        return {
          "status": true,
          "message": "Ocurrion un error, intente nuevamente." 
        };
    }

  }


  Future<void> updateCheckState(String idCheck) async {
    Company? companyNew = state.company;

    //companyNew?.cchkIdEstadoCheck = idCheck == '01' ? '06' : '01';
    companyNew?.cchkIdEstadoCheck = idCheck;

    state = state.copyWith(company: companyNew);
  }

  Future<void> loadSecundaryDetails() async {
    state = state.copyWith(
      isLoadingContacts: true,
      isLoadingOpportunities: true,
      isLoadingActivities: true,
      isLoadingEvents: true,
      isLoadingLocales: true
    );

    final contacts = await contactsRepository.getContacts(ruc: state.company!.ruc, search: '', limit: 100, offset: 0);
    final opportunities =
        await opportunitiesRepository.getOpportunitiesByName(ruc:state.company!.ruc);
    final activities = await activitiesRepository.getActivitiesByRuc(state.company!.ruc);
    final events = await eventsRepository.getEventsListByRuc(state.company!.ruc);
    final companyLocales =
        await companiesRepository.getCompanyLocales(state.company!.ruc);

    state = state.copyWith(
      contacts: contacts,
      isLoadingContacts: false,
      opportunities: opportunities,
      isLoadingOpportunities: false,
      activities: activities,
      isLoadingActivities: false,
      events: events,
      isLoadingEvents: false,
      companyLocales: companyLocales,
      isLoadingLocales: false
    );
  }

  Future<void> loadSecundaryLocales() async {
    if (state.isLoadingLocales) return;
    state = state.copyWith(isLoadingLocales: true);

    final companyLocales =
        await companiesRepository.getCompanyLocales(state.company!.ruc);
    state = state.copyWith(
      isLoadingLocales: false,
      companyLocales: companyLocales,
    );
  }

  Future<void> loadSecundaryContacts() async {
    //if (state.isLoadingContacts) return;
    state = state.copyWith(isLoadingContacts: true);

    final contacts = await contactsRepository.getContacts(ruc: state.company!.ruc, search: '', limit: 100, offset: 0);
    state = state.copyWith(
      isLoadingContacts: false,
      contacts: contacts,
    );
  }

  Future<void> loadSecundaryOpportunities() async {
    if (state.isLoadingOpportunities) return;
    state = state.copyWith(isLoadingOpportunities: true);

    final opportunities =
        await opportunitiesRepository.getOpportunitiesByName(ruc:state.company!.ruc);
    
    state = state.copyWith(
      isLoadingOpportunities: false,
      opportunities: opportunities,
    );
  }

  Future<void> loadSecundaryActivities() async {
    if (state.isLoadingActivities) return;
    state = state.copyWith(isLoadingActivities: true);

    final activities = await activitiesRepository.getActivitiesByRuc(state.company!.ruc);
    
    state = state.copyWith(
      isLoadingActivities: false,
      activities: activities,
    );
  }

  Future<void> loadSecundaryEvents() async {
    if (state.isLoadingEvents) return;

    state = state.copyWith(isLoadingEvents: true);

    final events = await eventsRepository.getEventsListByRuc(state.company!.ruc);
    
    state = state.copyWith(
      isLoadingEvents: false,
      events: events,
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
      log('state ruc' + state.rucId);
      final company = await companiesRepository.getCompanyById(state.rucId, user.code);
      log( "def" +company.ruc);
      company.rucId = company.ruc;
      
      /*final contacts = await contactsRepository.getContacts(ruc: company.ruc, search: '', limit: 100, offset: 0);
      final opportunities =
          await opportunitiesRepository.getOpportunities(ruc:company.ruc, search: '', limit: 100, offset: 0);
      final activities = await activitiesRepository.getActivitiesByRuc(company.ruc);
      final events = await eventsRepository.getEventsListByRuc(company.ruc);
      */
      final companyLocales =  await companiesRepository.getCompanyLocales(company.ruc);
      log('wwerwerwer');
      state = state.copyWith(
        isLoading: false,
        company: company,
        companyLocales: companyLocales
        /*contacts: contacts,
        opportunities: opportunities,
        activities: activities,
        events: events,
        companyLocales: companyLocales,*/
      );

    } catch (e) {
      // 404 product not found
      state = state.copyWith(isLoading: false, company: null);
      log("ddddd"+e.toString());
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
  final bool isLoadingLocales;
  final bool isLoadingContacts;
  final bool isLoadingOpportunities;
  final bool isLoadingActivities;
  final bool isLoadingEvents;
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
    this.isLoadingLocales = true,
    this.isLoadingContacts = true,
    this.isLoadingOpportunities = true,
    this.isLoadingActivities = true,
    this.isLoadingEvents = true,
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
    bool? isLoadingLocales,
    bool? isLoadingActivities,
    bool? isLoadingContacts,
    bool? isLoadingEvents,
    bool? isLoadingOpportunities,
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
        isLoadingLocales: isLoadingLocales ?? this.isLoadingLocales,
        isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
        isLoadingOpportunities: isLoadingOpportunities ?? this.isLoadingOpportunities,
        isLoadingActivities: isLoadingActivities ?? this.isLoadingActivities,
        isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
        isSaving: isSaving ?? this.isSaving,
      );
}

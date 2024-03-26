import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/providers/activities_repository_provider.dart';
import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/agenda/presentation/providers/events_repository_provider.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/contacts_repository_provider.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/opportunities_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';

import 'companies_repository_provider.dart';

final companyProvider = StateNotifierProvider.autoDispose
    .family<CompanyNotifier, CompanyState, String>((ref, rucId) {
  final companiesRepository = ref.watch(companiesRepositoryProvider);
  final contactsRepository = ref.watch(contactsRepositoryProvider);
  final opportunitiesRepository = ref.watch(opportunitiesRepositoryProvider);
  final activitiesRepository = ref.watch(activitiesRepositoryProvider);
  final eventsRepository = ref.watch(eventsRepositoryProvider);

  return CompanyNotifier(
      companiesRepository: companiesRepository,
      contactsRepository: contactsRepository,
      opportunitiesRepository: opportunitiesRepository,
      activitiesRepository: activitiesRepository,
      eventsRepository: eventsRepository,
      rucId: rucId);
});

class CompanyNotifier extends StateNotifier<CompanyState> {
  final CompaniesRepository companiesRepository;
  final ContactsRepository contactsRepository;
  final OpportunitiesRepository opportunitiesRepository;
  final ActivitiesRepository activitiesRepository;
  final EventsRepository eventsRepository;

  CompanyNotifier({
    required this.companiesRepository,
    required this.contactsRepository,
    required this.opportunitiesRepository,
    required this.activitiesRepository,
    required this.eventsRepository,
    required String rucId,
  }) : super(CompanyState(rucId: rucId)) {
    print('LLEGO COMPAN NOT');
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
      cchkIdEstadoCheck: '',
      ubigeoCodigo: '',
      voltajeTension: '',
      arrayresponsables: [],
      arrayresponsablesEliminar: [],
    );
  }

  Future<void> loadCompany() async {
    print('SATE RUC ID: ${state.rucId}');
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

      final contacts = await contactsRepository.getContacts(company.ruc);
      final opportunities =
          await opportunitiesRepository.getOpportunities(company.ruc);
      final activities = await activitiesRepository.getActivities();
      final events = await eventsRepository.getEventsList();
      final companyLocales = await companiesRepository.getCompanyLocales(company.ruc);

      print('LENT OPO: ${opportunities.length}');

      state = state.copyWith(
        isLoading: false,
        company: company,
        contacts: contacts,
        opportunities: opportunities,
        activities: activities,
        events: events,
        companyLocales: companyLocales,
      );
    } catch (e) {
      // 404 product not found
      state = state.copyWith(isLoading: false, company: null);
      print(e);
    }
  }

  Future<void> loadContacts(String ruc) async {
    try {
      final contacts = await contactsRepository.getContacts(ruc);
      state = state.copyWith(contacts: contacts);
    } catch (e) {
      state = state.copyWith(contacts: []);
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

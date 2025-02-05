import 'dart:developer';

import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/infrastructure/mappers/activity_mapper.dart';
import 'package:crm_app/features/companies/domain/entities/company.dart';
import 'package:crm_app/features/companies/infrastructure/mappers/company_mapper.dart';
import 'package:crm_app/features/contacts/domain/entities/contact.dart';
import 'package:crm_app/features/contacts/infrastructure/infrastructure.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/kpis_repository_provider.dart';
import 'package:crm_app/features/opportunities/domain/entities/opportunity.dart';
import 'package:crm_app/features/opportunities/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class TypeCategory {
  static String chekIns = '01';
  static String nuevoContacto = '07';
  static String nuevaOportunidad = '04';
  static String oportunidadesGanadas = '05';
  static String nuevaEmpresa = '03';
}

final selectKpiProvider = StateProvider<Kpi?>((ref) => null);

final kpisByCatNotifierProvider =
    StateNotifierProvider<KpisByCategoryNotifier, KpisByCategoryState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);
  final kpiProvider = ref.watch(selectKpiProvider);
  return KpisByCategoryNotifier(
    kpisRepository: kpisRepository,
    kpiProviders: kpiProvider,
  );
});

class KpisByCategoryNotifier extends StateNotifier<KpisByCategoryState> {
  final KpisRepository kpisRepository;
  final Kpi? kpiProviders;

  KpisByCategoryNotifier({
    required this.kpisRepository,
    required this.kpiProviders,
  }) : super(KpisByCategoryState()) {
    listKpiByCategory();
  }

  Future listKpiByCategory() async {
    log('message');
    final formData = {};
    formData['OBJR_ID_OBJETIVO'] = kpiProviders?.id.toString();
    formData['SEARCH'] = '';
    try {
      state = state.copyWith(
        isLoading: true,
        isLastPage: false,
        items: [],
      );
      if (kpiProviders?.objrIdCategoria == TypeCategory.chekIns) {
        formData['OBJR_ID_CATEGORIA'] = TypeCategory.chekIns;
        log(formData.toString());
        final response = await kpisRepository.listObjetiveByCategory(formData);
        var listCheckIns = <Activity>[];
        if (response.status) {
          final list = response.items;
          for (var item in list) {
            final model = ActivityMapper.jsonToEntity(item) as Activity;
            listCheckIns.add(model);
          }
        }
        state = state.copyWith(items: listCheckIns, isLoading: false);
        return;
      }
      if (kpiProviders?.objrIdCategoria == TypeCategory.nuevaEmpresa) {
        formData['OBJR_ID_CATEGORIA'] = TypeCategory.nuevaEmpresa;
        log(formData.toString());
        final response = await kpisRepository.listObjetiveByCategory(formData);
        var listModels = <Company>[];
        if (response.status) {
          final list = response.items;
          for (var item in list) {
            final model = CompanyMapper.jsonToEntity(item) as Company;
            listModels.add(model);
          }
        }
        state = state.copyWith(items: listModels, isLoading: false);
        return;
      }
      if (kpiProviders?.objrIdCategoria == TypeCategory.nuevoContacto) {
        formData['OBJR_ID_CATEGORIA'] = TypeCategory.nuevoContacto;
        log(formData.toString());
        final response = await kpisRepository.listObjetiveByCategory(formData);
        var listModels = <Contact>[];
        if (response.status) {
          final list = response.items;
          for (var item in list) {
            final model = ContactMapper.jsonToEntity(item) as Contact;
            listModels.add(model);
          }
        }
        state = state.copyWith(items: listModels, isLoading: false);
        return;
      }
      if (kpiProviders?.objrIdCategoria == TypeCategory.nuevaOportunidad) {
        formData['OBJR_ID_CATEGORIA'] = TypeCategory.nuevaOportunidad;
        log(formData.toString());
        final response = await kpisRepository.listObjetiveByCategory(formData);
        var listModels = <Opportunity>[];
        if (response.status) {
          final list = response.items;
          for (var item in list) {
            final model = OpportunityMapper.jsonToEntity(item) as Opportunity;
            listModels.add(model);
          }
        }
        state = state.copyWith(items: listModels, isLoading: false);
        return;
      }
      if (kpiProviders?.objrIdCategoria == TypeCategory.oportunidadesGanadas) {
        formData['OBJR_ID_CATEGORIA'] = TypeCategory.oportunidadesGanadas;
        log(formData.toString());
        final response = await kpisRepository.listObjetiveByCategory(formData);
        var listModels = <Opportunity>[];
        if (response.status) {
          final list = response.items;
          for (var item in list) {
            final model = OpportunityMapper.jsonToEntity(item) as Opportunity;
            listModels.add(model);
          }
        }
        state = state.copyWith(items: listModels, isLoading: false);
        return;
      }
      state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        items: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        items: [],
      );
    }
  }
}

class KpisByCategoryState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List items;

  KpisByCategoryState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.items = const []});

  KpisByCategoryState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List? items,
  }) =>
      KpisByCategoryState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        items: items ?? this.items,
      );
}

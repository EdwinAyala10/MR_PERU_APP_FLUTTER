import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kpis_repository_provider.dart';

final selecIndexViewProvider = StateProvider<int>((ref) => 1);

final goalsModelProvider = StateProvider<Kpi?>((ref) => null);

final kpisProvider = StateNotifierProvider<KpisNotifier, KpisState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return KpisNotifier(
    kpisRepository: kpisRepository,
    user: user!,
  );
});

class KpisNotifier extends StateNotifier<KpisState> {
  final KpisRepository kpisRepository;
  final User user;

  KpisNotifier({
    required this.kpisRepository,
    required this.user,
  }) : super(KpisState()) {
    loadNextPage();
  }

  Future<CreateUpdateKpiResponse> createOrUpdateKpi(
      Map<dynamic, dynamic> kpiLike) async {
    try {
      final kpiResponse = await kpisRepository.createUpdateKpi(kpiLike);

      final message = kpiResponse.message;

      if (kpiResponse.status) {
        //final kpi = kpiResponse.kpi as Kpi;
        //final isKpiInList = state.kpis.any((element) => element.id == kpi.id);

        /*if (!isKpiInList) {
          state = state.copyWith(kpis: [...state.kpis, kpi]);
          return CreateUpdateKpiResponse(response: true, message: message);
        }

        state = state.copyWith(
            kpis: state.kpis
                .map(
                  (element) => (element.id == kpi.id) ? kpi : element,
                )
                .toList());*/

        return CreateUpdateKpiResponse(response: true, message: message);
      }

      return CreateUpdateKpiResponse(response: false, message: message);
    } catch (e) {
      return CreateUpdateKpiResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }

  Future loadNextPage() async {
    print('cargar KPIS');
    //if (state.isLoading || state.isLastPage) return;
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final kpis = await kpisRepository.getKpis(user.code);

    if (kpis.isEmpty) {
      //state = state.copyWith(isLoading: false, isLastPage: true);
      state = state.copyWith(isLoading: false);
      return;
    }


    state = state.copyWith(
        //isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        kpis: kpis);

    await initialOrderkeyKpis();
    

    /*state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        kpis: [...state.kpis, ...kpis]);*/
  }

  Future updateOrderKpis({ String idKpiOld = '', String orderKpiOld = '', String idKpiNew = '', String orderKpiNew = '' }) async {
    print('UPDATE ORDER KPIS');

    final kpis = await kpisRepository.updateOrderKpis(idKpiOld: idKpiOld, orderKpiOld: orderKpiOld, idKpiNew: idKpiNew, orderKpiNew: orderKpiNew);

    print('Se proceso ORDER KPIS');
  }

  int indexOfKey(Key key) {
    return state.kpis
        .indexWhere((Kpi d) => d.key == key);
  }

  Kpi searchItemBhyKey(Key key) {
    return state.kpis
        .firstWhere((Kpi d) => d.key == key);
  }

  bool onReorder(
      Key item, Key newPosition, List<Kpi> list) {
    int draggingIndex = indexOfKey(item);
    int newPositionIndex = indexOfKey(newPosition);

    Kpi oldItem = searchItemBhyKey(item);
    Kpi newItem = searchItemBhyKey(newPosition);

    print(oldItem.id);
    print(oldItem.key.toString());
    print(draggingIndex);

    print('........');

    print(newItem.id);
    print(newItem.key.toString());
    print(newPositionIndex);

    updateOrderKpis(idKpiOld: oldItem.id, orderKpiOld: draggingIndex.toString(), idKpiNew: newItem.id, orderKpiNew: newPositionIndex.toString());

    final draggedItem = state.kpis[draggingIndex];

    final newListSelectedItems = [...state.kpis];

    newListSelectedItems.removeAt(draggingIndex);
    newListSelectedItems.insert(newPositionIndex, draggedItem);

    state = state.copyWith(kpis: newListSelectedItems);

    return true;
  }

  Future<void> setSelectedItemsOrder(
      List<Kpi> selectedItemsOrder) async {
    state = state.copyWith(
      kpis: selectedItemsOrder,
    );
  }

  Future<void> initialOrderkeyKpis() async {
    List<Kpi> newListItemsSelected = [];
    List<Kpi> oldListItemsSelected = state.kpis;

    for (var i = 0; i < oldListItemsSelected.length; i++) {
      Kpi local = oldListItemsSelected[i];
      local.key = ValueKey(i);

      newListItemsSelected.add(local);
    }

    state = state.copyWith(kpis: newListItemsSelected);
  }

  /*Future loadKpisDashboard() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final kpis = await kpisRepository.getKpisForDashboard();

    if (kpis.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        kpis: [...state.kpis, ...kpis]);
  }*/
}

class KpisState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Kpi> kpis;

  KpisState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.kpis = const []});

  KpisState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Kpi>? kpis,
  }) =>
      KpisState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        kpis: kpis ?? this.kpis,
      );
}

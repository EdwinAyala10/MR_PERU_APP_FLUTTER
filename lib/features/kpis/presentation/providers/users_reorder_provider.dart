import 'dart:async';
import 'package:crm_app/features/kpis/presentation/providers/kpis_repository_provider.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersReorderProvider =
    StateNotifierProvider<UsersReorderNotifier, UsersReorderState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);

  return UsersReorderNotifier(
    kpisRepository: kpisRepository,
  );
});

class UsersReorderNotifier extends StateNotifier<UsersReorderState> {
  final kpisRepository;
  Timer? _debounce;

  UsersReorderNotifier({
    required this.kpisRepository,
  }) : super(UsersReorderState()) {
    loadUsers('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> loadUsers(String search) async {
    state = state.copyWith(isLoading: true, searchQuery: search);

    final users = await kpisRepository.getUsersByType(search);

    state = state.copyWith(
      isLoading: false,
      users: users,
    );

    await initialOrderKeyUsers();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadUsers(query);
    });
  }

  Future<void> initialOrderKeyUsers() async {
    List<UserMaster> newListUsers = [];
    List<UserMaster> oldListUsers = state.users;

    for (var i = 0; i < oldListUsers.length; i++) {
      UserMaster user = oldListUsers[i];
      // Crear un nuevo UserMaster con la key asignada
      // Como UserMaster no tiene key, la manejamos en el widget
      newListUsers.add(user);
    }

    state = state.copyWith(users: newListUsers);
  }

  int indexOfKey(Key key) {
    return state.users.indexWhere((UserMaster u) {
      // Comparamos usando el índice como key
      final index = state.users.indexOf(u);
      return ValueKey(index) == key;
    });
  }

  UserMaster searchItemByKey(Key key) {
    final index = indexOfKey(key);
    return state.users[index];
  }

  bool onReorder(Key item, Key newPosition, List<UserMaster> list) {
    int draggingIndex = indexOfKey(item);
    int newPositionIndex = indexOfKey(newPosition);

    UserMaster oldUser = searchItemByKey(item);
    UserMaster newUser = searchItemByKey(newPosition);

    final draggedItem = state.users[draggingIndex];

    final newListUsers = [...state.users];

    newListUsers.removeAt(draggingIndex);
    newListUsers.insert(newPositionIndex, draggedItem);

    state = state.copyWith(
      users: newListUsers,
      idUserOld: oldUser.id,
      codeUserOld: oldUser.code,
      idUserNew: newUser.id,
      codeUserNew: newUser.code,
    );

    return true;
  }

  Future<void> updateUsersOrder() async {
    print('UPDATE ORDER USERS');
    print('State idUserOld: ${state.idUserOld}');
    print('State codeUserOld: ${state.codeUserOld}');
    print('State idUserNew: ${state.idUserNew}');
    print('State codeUserNew: ${state.codeUserNew}');

    // Construir el array completo con el nuevo orden
    List<Map<String, String>> usuariosOrdenados = [];

    for (var i = 0; i < state.users.length; i++) {
      usuariosOrdenados.add({
        'USERREPORT_CODIGO': state.users[i].code,
        'USERREPORT_ORDEN_OBJETIVO': (i + 1).toString(),
      });
    }

    final success = await kpisRepository.updateUsersOrder(usuariosOrdenados);

    if (success) {
      print('Orden actualizado correctamente');
    } else {
      print('Error al actualizar orden');
    }
  }
}

class UsersReorderState {
  final List<UserMaster> users;
  final String searchQuery;
  final bool isLoading;
  final String? idUserOld;
  final String? codeUserOld;
  final String? idUserNew;
  final String? codeUserNew;

  UsersReorderState({
    this.users = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.idUserOld,
    this.codeUserOld,
    this.idUserNew,
    this.codeUserNew,
  });

  UsersReorderState copyWith({
    List<UserMaster>? users,
    String? searchQuery,
    bool? isLoading,
    String? idUserOld,
    String? codeUserOld,
    String? idUserNew,
    String? codeUserNew,
  }) =>
      UsersReorderState(
        users: users ?? this.users,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        idUserOld: idUserOld ?? this.idUserOld,
        codeUserOld: codeUserOld ?? this.codeUserOld,
        idUserNew: idUserNew ?? this.idUserNew,
        codeUserNew: codeUserNew ?? this.codeUserNew,
      );
}

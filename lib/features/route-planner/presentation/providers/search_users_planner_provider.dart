import 'dart:developer';

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/auth/domain/entities/user.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/route-planner/domain/entities/users_planner_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedUserPlannerProvider =
    StateProvider<UsersPlannerModel?>((ref) => null);

final searchUsersPlannerProvider =
    StateNotifierProvider<SearchUserPlannerNotifier, List<UsersPlannerModel>>(
  (ref) {
    final user = ref.read(authProvider);
    return SearchUserPlannerNotifier(
      [],
      user: user.user,
    );
  },
);

class SearchUserPlannerNotifier extends StateNotifier<List<UsersPlannerModel>> {
  final User? user;
  SearchUserPlannerNotifier(super.state, {required this.user}){
    getAllUsersPlannerList('');
  }

  Future<List<UsersPlannerModel>> getAllUsersPlannerList(String? search) async {
    final client = Dio(
      BaseOptions(
        headers: {'Authorization': 'Bearer ${user?.token}'},
      ),
    );
    String path = Environment.apiUrl;
    String url = "$path/user/listar-usuarios-by-tipo?SEARCH=${search??''}";
    try {
      final response = await client.get(url);
      if (response.data['status'] == true) {
        final list = <UsersPlannerModel>[];
        for (var v in response.data['data']) {
          list.add(UsersPlannerModel.fromJson(v));
        }
        log('wfwef'+list.length.toString());
        state = [];
        state = list;
        return state;
      }
      state = [];
      return state;
    } catch (e) {
      state = [];
      return state;
    }
  }

  Future<List<UsersPlannerModel>> searchCompaniesByQuery(String search) async {
    final List<UsersPlannerModel> companies = await getAllUsersPlannerList(search);
    state = companies;
    return companies;
  }


}

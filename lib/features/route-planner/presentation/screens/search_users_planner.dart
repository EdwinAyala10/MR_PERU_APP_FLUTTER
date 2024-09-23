import 'package:crm_app/features/route-planner/presentation/providers/search_users_planner_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchUsersPlanner extends ConsumerStatefulWidget {
  static const String name = 'SearchUsersPlanner';
  const SearchUsersPlanner({super.key});

  @override
  ConsumerState<SearchUsersPlanner> createState() => _SearchUsersPlannerState();
}

class _SearchUsersPlannerState extends ConsumerState<SearchUsersPlanner> {
  final controllerSearchUser = TextEditingController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(searchUsersPlannerProvider.notifier).getAllUsersPlannerList('');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listUsers = ref.watch(searchUsersPlannerProvider);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: TextFormField(
          controller: controllerSearchUser,
          decoration: const InputDecoration(
            hintText: 'Seleccione un usuario',
            hintStyle: TextStyle(
              color: Colors.blueGrey
            ),
            border: InputBorder.none,
          ),
          onChanged: (v) {
            ref
                .read(searchUsersPlannerProvider.notifier)
                .searchCompaniesByQuery(
                  controllerSearchUser.text,
                );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(searchUsersPlannerProvider.notifier)
                  .searchCompaniesByQuery(
                    controllerSearchUser.text,
                  );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Column(
        children: [
          listUsers.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      final user = listUsers[index];
                      return ListTile(
                        title: Text(user.userreportName ?? ''),
                        subtitle: Text(user.userreportCodigo ?? ''),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            user.userreportAbbrt ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          ref.read(selectedUserPlannerProvider.notifier).state =
                              listUsers[index];
                          context.pop();
                        },
                      );
                    },
                    itemCount: listUsers.length,
                  ),
                ),
        ],
      ),
    );
  }
}

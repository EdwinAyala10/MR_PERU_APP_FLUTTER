import 'dart:async';
import 'package:crm_app/features/kpis/presentation/providers/users_reorder_provider.dart';
import 'package:crm_app/features/kpis/presentation/widgets/item_user_reorder.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KpiReorderByUserScreen extends StatelessWidget {
  const KpiReorderByUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _SearchAppBar(),
      body: _UsersReorderView(),
    );
  }
}

class _SearchAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const _SearchAppBar();

  @override
  ConsumerState<_SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends ConsumerState<_SearchAppBar> {
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: TextField(
        controller: searchController,
        onChanged: (String value) {
          ref.read(usersReorderProvider.notifier).onSearchChanged(value);
        },
        decoration: const InputDecoration(
          hintText: 'Buscar personas...',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
      actions: const [
        SizedBox(width: 8),
      ],
    );
  }
}

class _UsersReorderView extends ConsumerStatefulWidget {
  const _UsersReorderView();

  @override
  _UsersReorderViewState createState() => _UsersReorderViewState();
}

class _UsersReorderViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final searchQuery = ref.read(usersReorderProvider).searchQuery;
    ref.read(usersReorderProvider.notifier).loadUsers(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersReorderProvider);

    return usersState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : usersState.users.isEmpty
            ? Center(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron usuarios',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : _ListUsers(
                users: usersState.users,
                onRefreshCallback: _refresh,
              );
  }
}

class _ListUsers extends ConsumerWidget {
  final List<UserMaster> users;
  final Future<void> Function() onRefreshCallback;

  const _ListUsers({
    required this.users,
    required this.onRefreshCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefreshCallback,
      child: ReorderableList(
        onReorder: (Key item, Key newPosition) {
          return ref
              .read(usersReorderProvider.notifier)
              .onReorder(item, newPosition, users);
        },
        onReorderDone: (Key item) async {
          print('EJECUTA ON REORDER DONE');
          await ref.read(usersReorderProvider.notifier).updateUsersOrder();
        },
        child: CustomScrollView(
          controller: ScrollController(),
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ItemUserReorder(
                      user: users[index],
                      isFirst: index == 0,
                      isLast: index == users.length - 1,
                      index: index,
                      onTap: () {
                        // Opcional: acción al tocar el item
                      },
                    );
                  },
                  childCount: users.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

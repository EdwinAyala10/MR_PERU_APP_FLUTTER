import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchUsersCallback = Future<List<UserMaster>> Function(String query);
typedef ResetSearchQueryCallback = void Function();

class SearchUserDelegate extends SearchDelegate<UserMaster?> {
  final SearchUsersCallback searchUsers;
  final ResetSearchQueryCallback resetSearchQuery;
  List<UserMaster> initialUsers;
  
  late StreamController<List<UserMaster>> debouncedUsers;
  late StreamController<bool> isLoadingStream;

  Timer? _debounceTimer;

  SearchUserDelegate({
    required this.searchUsers,
    required this.resetSearchQuery,
    required this.initialUsers,
  }) : super(
          searchFieldLabel: 'Buscar personas',
          searchFieldStyle: const TextStyle(color: Colors.black45, fontSize: 16),
        ) {
    _initializeStreams();
  }

  void _initializeStreams() {
    debouncedUsers = StreamController.broadcast();
    isLoadingStream = StreamController.broadcast();
  }

  void clearStreams() {
    debouncedUsers.close();
    isLoadingStream.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final users = await searchUsers(query);
      initialUsers = users;
      debouncedUsers.add(users);
      isLoadingStream.add(false);
    });
  }

  /*Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialUsers,
      stream: debouncedUsers.stream,
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Text(
              'No existen registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: users.length,
          itemBuilder: (context, index) => _UserItem(
            user: users[index],
            onUserSelected: (context, user) {
              clearStreams();
              close(context, user);
            },
          ),
        );
      },
    );
  }*/

  Widget buildResultsAndSuggestions() {
    return FutureBuilder<List<UserMaster>>(
      future: searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar los datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No existen registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else {
          final users = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemCount: users.length,
            itemBuilder: (context, index) => _UserItem(
              user: users[index],
              onUserSelected: (context, user) {
                clearStreams();
                close(context, user);
              },
            ),
          );
        }
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              spins: 10,
              infinite: true,
              child: IconButton(
                onPressed: () => query = '',
                icon: const Icon(Icons.refresh_rounded),
              ),
            );
          }

          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
              onPressed: () => query = '',
              icon: const Icon(Icons.clear),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        resetSearchQuery();
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return buildResultsAndSuggestions();
  }

  @override
  void close(BuildContext context, UserMaster? result) {
    query = '';
    clearStreams();
    resetSearchQuery();
    super.close(context, result);
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    clearStreams();
    _initializeStreams();
    _onQueryChanged(query);
  }
}

class _UserItem extends StatelessWidget {
  final UserMaster user;
  final Function onUserSelected;

  const _UserItem({
    required this.user,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onUserSelected(context, user);
      },
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: size.width * 0.2,
                child: const Icon(
                  Icons.perm_contact_cal,
                  size: 38,
                ),
              ),
              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: textStyles.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(user.code, overflow: TextOverflow.ellipsis),
                    Text(user.email ?? '', overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

typedef SearchUsersCallback = Future<List<UserMaster>> Function( String query );

class SearchUserDelegate extends SearchDelegate<UserMaster?>{

  final SearchUsersCallback searchUsers;
  List<UserMaster> initialUsers;
  
  StreamController<List<UserMaster>> debouncedUsers = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  SearchUserDelegate({
    required this.searchUsers,
    required this.initialUsers,
  }):super(
    searchFieldLabel: 'Buscar personas',
    // textInputAction: TextInputAction.done
  );

  void clearStreams() {
    debouncedUsers.close();
  }

  void _onQueryChanged( String query ) {
    isLoadingStream.add(true);

    if ( _debounceTimer?.isActive ?? false ) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration( milliseconds: 500 ), () async {
      // if ( query.isEmpty ) {
      //   debouncedCompanies.add([]);
      //   return;
      // }

      final users = await searchUsers( query );

      initialUsers = users;
      debouncedUsers.add(users);
      isLoadingStream.add(false);

    });

  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialUsers,
      stream: debouncedUsers.stream,
      builder: (context, snapshot) {
        
        final users = snapshot.data ?? [];

        return ListView.builder(
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
  }


  // @override
  // String get searchFieldLabel => 'Buscar empresa';

  @override
  List<Widget>? buildActions(BuildContext context) {

    return [

      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
            if ( snapshot.data ?? false ) {
              return SpinPerfect(
                  duration: const Duration(seconds: 20),
                  spins: 10,
                  infinite: true,
                  child: IconButton(
                    onPressed: () => query = '', 
                    icon: const Icon( Icons.refresh_rounded )
                  ),
                );
            }

             return FadeIn(
                animate: query.isNotEmpty,
                child: IconButton(
                  onPressed: () => query = '', 
                  icon: const Icon( Icons.clear )
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
          close(context, null);
        }, 
        icon: const Icon( Icons.arrow_back_ios_new_rounded)
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

}

class _UserItem extends StatelessWidget {

  final UserMaster user;
  final Function onUserSelected;

  const _UserItem({
    required this.user,
    required this.onUserSelected
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
          
              // Image
              SizedBox(
                width: size.width * 0.2,
                child: const Icon(
                  Icons.blinds_outlined
                ),
              ),
          
              const SizedBox(width: 10),
              
              // Description
              SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( 
                      user.name, 
                      style: textStyles.titleMedium,
                    ),
                    Text( user.code ?? ''),
                    Text( user.email ?? ''),
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
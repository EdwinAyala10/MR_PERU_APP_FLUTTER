import '../../domain/domain.dart';
import '../providers/users_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchQueryUsersProvider = StateProvider<String>((ref) => '');

final searchedUsersProvider = StateNotifierProvider<SearchedUsersNotifier, List<UserMaster>>((ref) {

  final userRepository = ref.read( usersRepositoryProvider );

  return SearchedUsersNotifier(
    searchUsers: userRepository.searchUsers, 
    ref: ref
  );
});


typedef SearchUsersCallback = Future<List<UserMaster>> Function(String query);

class SearchedUsersNotifier extends StateNotifier<List<UserMaster>> {

  final SearchUsersCallback searchUsers;
  final Ref ref;

  SearchedUsersNotifier({
    required this.searchUsers,
    required this.ref,
  }): super([]);


  Future<List<UserMaster>> searchUsersByQuery( String query ) async{
    
    final List<UserMaster> users = await searchUsers(query);
    ref.read(searchQueryUsersProvider.notifier).update((state) => query);

    state = users;
    return users;
  }

}







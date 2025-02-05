import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uiProvider =
    StateNotifierProvider<UiNotifier, UiState>((ref) {
  //final authRepository = AuthRepositoryImpl();
  final user = ref.watch(authProvider).user;

  return UiNotifier(
    user: user!,
  );
});

class UiNotifier extends StateNotifier<UiState> {
  final User user;

  UiNotifier({
    required this.user,
  }) : super(UiState());


  void onCompanyActivity(String id, String name) {
    state = state.copyWith(
      idCompanyAct: id,
      nameCompanyAct: name
    );
  }

  void deleteCompanyActivity() {
    state = state.copyWith(
      idCompanyAct: '',
      nameCompanyAct: ''
    );
  }

}

class UiState {
  final String? idCompanyAct;
  final String? nameCompanyAct;

  UiState({
    this.idCompanyAct = '',
    this.nameCompanyAct = '',
  });

  UiState copyWith({
    String? idCompanyAct,
    String? nameCompanyAct,
  }) =>
      UiState(
        idCompanyAct: idCompanyAct ?? this.idCompanyAct,
        nameCompanyAct: nameCompanyAct ?? this.nameCompanyAct,
      );
}

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

  void setDashboardSuccessMessage({
    required String title,
    required String message,
  }) {
    state = state.copyWith(
      dashboardSuccessTitle: title,
      dashboardSuccessMessage: message,
    );
  }

  void clearDashboardSuccessMessage() {
    state = state.copyWith(
      dashboardSuccessTitle: '',
      dashboardSuccessMessage: '',
    );
  }

}

class UiState {
  final String? idCompanyAct;
  final String? nameCompanyAct;
  final String? dashboardSuccessTitle;
  final String? dashboardSuccessMessage;

  UiState({
    this.idCompanyAct = '',
    this.nameCompanyAct = '',
    this.dashboardSuccessTitle = '',
    this.dashboardSuccessMessage = '',
  });

  UiState copyWith({
    String? idCompanyAct,
    String? nameCompanyAct,
    String? dashboardSuccessTitle,
    String? dashboardSuccessMessage,
  }) =>
      UiState(
        idCompanyAct: idCompanyAct ?? this.idCompanyAct,
        nameCompanyAct: nameCompanyAct ?? this.nameCompanyAct,
        dashboardSuccessTitle:
            dashboardSuccessTitle ?? this.dashboardSuccessTitle,
        dashboardSuccessMessage:
            dashboardSuccessMessage ?? this.dashboardSuccessMessage,
      );
}

import 'package:crm_app/features/shared/domain/entities/send_email_request.dart';
import 'package:crm_app/features/shared/domain/repositories/email_repository.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/shared/infrastructure/datasources/email_datasource_impl.dart';
import 'package:crm_app/features/shared/infrastructure/repositories/email_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  final accessToken = ref.watch(authProvider).user?.token ?? '';
  return EmailRepositoryImpl(
    EmailDatasourceImpl(accessToken: accessToken),
  );
});

class EmailSendState {
  final bool isLoading;
  final bool? success;
  final String? message;
  final dynamic data;

  const EmailSendState({
    this.isLoading = false,
    this.success,
    this.message,
    this.data,
  });

  EmailSendState copyWith({
    bool? isLoading,
    bool? success,
    String? message,
    dynamic data,
  }) {
    return EmailSendState(
      isLoading: isLoading ?? this.isLoading,
      success: success,
      message: message,
      data: data,
    );
  }
}

class EmailSendNotifier extends StateNotifier<EmailSendState> {
  final EmailRepository repository;

  EmailSendNotifier(this.repository) : super(const EmailSendState());

  Future<bool> sendEmail(SendEmailRequest request) async {
    state = state.copyWith(isLoading: true, message: null);

    final response = await repository.sendEmail(request);
    state = state.copyWith(
      isLoading: false,
      success: response.success,
      message: response.message,
      data: response.data,
    );

    return response.success;
  }

  void reset() {
    state = const EmailSendState();
  }
}

final emailSendProvider = StateNotifierProvider<EmailSendNotifier, EmailSendState>((ref) {
  final repository = ref.watch(emailRepositoryProvider);
  return EmailSendNotifier(repository);
});

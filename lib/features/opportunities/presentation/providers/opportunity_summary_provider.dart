import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../config/constants/environment.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/opportunity_summary.dart';
import '../../infrastructure/datasources/opportunity_summary_datasource_impl.dart';
import '../../infrastructure/repositories/opportunity_summary_repository_impl.dart';

// Provider del datasource
final opportunitySummaryDatasourceProvider = Provider<OpportunitySummaryDatasourceImpl>((ref) {
  final authState = ref.watch(authProvider);
  final token = authState.user?.token ?? '';
  
  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {'Authorization': 'Bearer $token'},
  ));
  
  return OpportunitySummaryDatasourceImpl(dio: dio);
});

// Provider del repository
final opportunitySummaryRepositoryProvider = Provider<OpportunitySummaryRepositoryImpl>((ref) {
  final datasource = ref.watch(opportunitySummaryDatasourceProvider);
  return OpportunitySummaryRepositoryImpl(datasource: datasource);
});

// State del summary
class OpportunitySummaryState {
  final bool isLoading;
  final OpportunitySummary? summary;
  final String? errorMessage;

  OpportunitySummaryState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  OpportunitySummaryState copyWith({
    bool? isLoading,
    OpportunitySummary? summary,
    String? errorMessage,
  }) {
    return OpportunitySummaryState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier
class OpportunitySummaryNotifier extends StateNotifier<OpportunitySummaryState> {
  final OpportunitySummaryRepositoryImpl repository;

  OpportunitySummaryNotifier({required this.repository}) : super(OpportunitySummaryState());

  Future<void> generateSummary(String opportunityId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final summary = await repository.generateSummary(opportunityId);
      
      if (summary.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          summary: summary,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: summary.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = OpportunitySummaryState();
  }
}

// Provider principal
final opportunitySummaryProvider = StateNotifierProvider.family<OpportunitySummaryNotifier, OpportunitySummaryState, String>(
  (ref, opportunityId) {
    final repository = ref.watch(opportunitySummaryRepositoryProvider);
    return OpportunitySummaryNotifier(repository: repository);
  },
);

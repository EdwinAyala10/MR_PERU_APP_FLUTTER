import '../../domain/datasources/opportunity_summary_datasource.dart';
import '../../domain/entities/opportunity_summary.dart';
import '../../domain/repositories/opportunity_summary_repository.dart';

class OpportunitySummaryRepositoryImpl extends OpportunitySummaryRepository {
  final OpportunitySummaryDatasource datasource;

  OpportunitySummaryRepositoryImpl({required this.datasource});

  @override
  Future<OpportunitySummary> generateSummary(String opportunityId) {
    return datasource.generateSummary(opportunityId);
  }
}

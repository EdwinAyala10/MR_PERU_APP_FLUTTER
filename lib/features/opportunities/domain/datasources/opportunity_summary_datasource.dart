import '../entities/opportunity_summary.dart';

abstract class OpportunitySummaryDatasource {
  Future<OpportunitySummary> generateSummary(String opportunityId);
}

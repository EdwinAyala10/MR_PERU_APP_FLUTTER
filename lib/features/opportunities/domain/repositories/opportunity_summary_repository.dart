import '../entities/opportunity_summary.dart';

abstract class OpportunitySummaryRepository {
  Future<OpportunitySummary> generateSummary(String opportunityId);
}

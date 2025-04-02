import '../domain.dart';
import '../entities/status_opportunity.dart';

abstract class OpportunitiesDatasource {
  Future<List<Opportunity>> getOpportunities({
    String ruc,
    String search,
    int limit = 10,
    int offset = 0,
    String idUsuario = '',
  });

  Future<List<Opportunity>> getListOpportunities({
    String ruc,
    String search,
    int limit = 10,
    int offset = 0,
    String? idUsuario,
    String? estado,
    String? estadoOP,
    String? startDate,
    String? endDate,
    String? startValue,
    String? endValue,
    String? startPercent,
    String? endPercent,
  });

  Future<List<Opportunity>> getOpportunitiesByName({
    String ruc,
    String name,
  });
  Future<Opportunity> getOpportunityById(String id);

  Future<OpportunityResponse> createUpdateOpportunity(
    Map<dynamic, dynamic> opportunityLike,
  );

  Future<List<StatusOpportunity>> getStatusOpportunityByPeriod();

  Future<List<Opportunity>> searchOpportunities(
    String ruc,
    String query,
  );
}

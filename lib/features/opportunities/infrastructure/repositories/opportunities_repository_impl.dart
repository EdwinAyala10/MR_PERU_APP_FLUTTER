import '../../domain/domain.dart';
import '../../domain/entities/status_opportunity.dart';

class OpportunitiesRepositoryImpl extends OpportunitiesRepository {
  final OpportunitiesDatasource datasource;

  OpportunitiesRepositoryImpl(this.datasource);

  @override
  Future<OpportunityResponse> createUpdateOpportunity(
      Map<dynamic, dynamic> opportunityLike) {
    return datasource.createUpdateOpportunity(opportunityLike);
  }

  @override
  Future<Opportunity> getOpportunityById(String id) {
    return datasource.getOpportunityById(id);
  }

  @override
  Future<List<Opportunity>> getOpportunities({String ruc = '', String search = '',  int limit = 10, int offset = 0}) {
    return datasource.getOpportunities(ruc: ruc, search: search, offset: offset, limit: limit);
  }

  @override
  Future<List<Opportunity>> searchOpportunities(String ruc, String query) {
    return datasource.searchOpportunities(ruc, query);
  }

  @override
  Future<List<StatusOpportunity>> getStatusOpportunityByPeriod() {
    return datasource.getStatusOpportunityByPeriod();
  }
}

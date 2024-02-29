import 'package:crm_app/features/opportunities/domain/domain.dart';

class OpportunitiesRepositoryImpl extends OpportunitiesRepository {

  final OpportunitiesDatasource datasource;

  OpportunitiesRepositoryImpl(this.datasource);

  @override
  Future<OpportunityResponse> createUpdateOpportunity(Map<dynamic, dynamic> opportunityLike) {
    return datasource.createUpdateOpportunity(opportunityLike);
  }

  @override
  Future<Opportunity> getOpportunityById(String id) {
    return datasource.getOpportunityById(id);
  }

  @override
  Future<List<Opportunity>> getOpportunities() {
    return datasource.getOpportunities();
  }

}
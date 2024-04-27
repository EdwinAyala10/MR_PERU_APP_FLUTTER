import 'package:crm_app/features/opportunities/domain/domain.dart';

abstract class OpportunitiesDatasource {

  Future<List<Opportunity>> getOpportunities(String ruc, String search);
  Future<Opportunity> getOpportunityById(String id);

  Future<OpportunityResponse> createUpdateOpportunity( Map<dynamic,dynamic> opportunityLike );

  Future<List<Opportunity>> searchOpportunities(String ruc, String query);
}


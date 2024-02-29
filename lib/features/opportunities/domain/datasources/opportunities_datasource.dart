import 'package:crm_app/features/opportunities/domain/domain.dart';

abstract class OpportunitiesDatasource {

  Future<List<Opportunity>> getOpportunities();
  Future<Opportunity> getOpportunityById(String id);

  Future<OpportunityResponse> createUpdateOpportunity( Map<dynamic,dynamic> opportunityLike );

}


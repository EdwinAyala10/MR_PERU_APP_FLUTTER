import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/domain/entities/status_opportunity.dart';


abstract class OpportunitiesRepository {

  Future<List<Opportunity>> getOpportunities(String ruc, String search);
  Future<Opportunity> getOpportunityById(String id);

  Future<OpportunityResponse> createUpdateOpportunity( Map<dynamic,dynamic> opportunityLike );
  
  Future<List<StatusOpportunity>> getStatusOpportunityByPeriod();

  Future<List<Opportunity>> searchOpportunities(String ruc, String query);
}


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
  Future<List<Opportunity>> getOpportunities(
      {String ruc = '',
      String search = '',
      int limit = 10,
      int offset = 0,
      String idUsuario = ''}) {
    return datasource.getOpportunities(
        ruc: ruc,
        search: search,
        offset: offset,
        limit: limit,
        idUsuario: idUsuario);
  }

  @override
  Future<List<Opportunity>> searchOpportunities(String ruc, String query) {
    return datasource.searchOpportunities(ruc, query);
  }

  @override
  Future<List<StatusOpportunity>> getStatusOpportunityByPeriod() {
    return datasource.getStatusOpportunityByPeriod();
  }

  @override
  Future<List<Opportunity>> getOpportunitiesByName(
      {String ruc = '', String name = ''}) {
    return datasource.getOpportunitiesByName(ruc: ruc, name: name);
  }

  @override
  Future<List<Opportunity>> getListOpportunities({
    required String ruc,
    required String search,
    required int limit,
    required int offset,
    required String idUsuario,
    required String estado,
    String startDate = '',
    String endDate = '',
    String startValue = '',
    String endValue = '',
    String startPercent = '',
    String endPercent = '',
  }) {
    return datasource.getListOpportunities(
      ruc: ruc,
      search: search,
      limit: limit,
      offset: offset,
      idUsuario: idUsuario,
      estado: estado,
      startDate: startDate,
      endDate: endDate,
      startValue: startValue,
      endValue: endValue,
      startPercent: startPercent,
    );
  }
}

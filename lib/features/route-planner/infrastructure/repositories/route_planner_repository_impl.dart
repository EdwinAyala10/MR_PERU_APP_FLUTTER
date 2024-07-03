
import '../../domain/domain.dart';

class RoutePlannerRepositoryImpl extends RoutePlannerRepository {
  final RoutePlannerDatasource datasource;

  RoutePlannerRepositoryImpl(this.datasource);


  @override
  Future<List<CompanyLocalRoutePlanner>> getCompanyLocals({ int limit = 10, int offset = 0, String search = '' }) {
    return datasource.getCompanyLocals(limit: limit, offset: offset, search: search);
  }

}

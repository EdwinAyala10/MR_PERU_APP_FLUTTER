
import '../domain.dart';

abstract class RoutePlannerRepository {

  Future<List<CompanyLocalRoutePlanner>> getCompanyLocals({ int limit = 10, int offset = 0, String search });

}


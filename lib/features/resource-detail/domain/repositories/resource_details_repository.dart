import '../domain.dart';

abstract class ResourceDetailsRepository {

  Future<List<ResourceDetail>> getResourceDetailsByGroup({ String idGroup = '', String idCodigo = '', String search = '' });
  Future<List<ResourceDetail>> getResourceDetailsVisibleByGroup({ String idGroup = '', String idCodigo = '' });
  Future<RubroResponse> createRubro(String nombre);
  Future<RubroResponse> editRubro(String nombre, String idRecursos);

}

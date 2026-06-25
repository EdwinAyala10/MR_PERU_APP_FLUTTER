import '../../domain/domain.dart';

class ResourceDetailsRepositoryImpl extends ResourceDetailsRepository {
  final ResourceDetailsDatasource datasource;

  ResourceDetailsRepositoryImpl(this.datasource);

  @override
  Future<List<ResourceDetail>> getResourceDetailsByGroup(
      {String idGroup = '', String idCodigo = '', String search = ''}) {
    return datasource.getResourceDetailsByGroup(
        idGroup: idGroup, idCodigo: idCodigo, search: search);
  }

  @override
  Future<List<ResourceDetail>> getResourceDetailsVisibleByGroup(
      {String idGroup = '', String idCodigo = ''}) {
    return datasource.getResourceDetailsVisibleByGroup(
        idGroup: idGroup, idCodigo: idCodigo);
  }

  @override
  Future<RubroResponse> createRubro(String nombre) {
    return datasource.createRubro(nombre);
  }

  @override
  Future<RubroResponse> editRubro(String nombre, String idRecursos) {
    return datasource.editRubro(nombre, idRecursos);
  }
}

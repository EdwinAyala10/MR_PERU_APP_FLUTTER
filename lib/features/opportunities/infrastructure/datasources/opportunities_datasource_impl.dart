import 'dart:developer';

import '../../domain/entities/status_opportunity.dart';
import '../mappers/opportunity_response_mapper.dart';
import '../mappers/status_opportunity_mapper.dart';
import 'package:dio/dio.dart';
import '../../../../config/config.dart';
import '../../domain/domain.dart';

import '../errors/opportunity_errors.dart';
import '../mappers/opportunity_mapper.dart';

class OpportunitiesDatasourceImpl extends OpportunitiesDatasource {
  late final Dio dio;
  final String accessToken;

  OpportunitiesDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<OpportunityResponse> createUpdateOpportunity(
      Map<dynamic, dynamic> opportunityLike) async {
    try {
      final String? id = opportunityLike['OPRT_ID_OPORTUNIDAD'];
      const String method = 'POST';
      final String url = (id == null)
          ? '/oportunidad/create-oportunidad'
          : '/oportunidad/edit-oportunidad';

      if (id == null) {
        opportunityLike.remove('OPRT_ID_OPORTUNIDAD');
      }
      //ORES_ID_USUARIO_RESPONSABLE
      log(opportunityLike.toString());
      final response = await dio.request(url,
          data: opportunityLike, options: Options(method: method));

      final OpportunityResponse opportunityResponse =
          OpportunityResponseMapper.jsonToEntity(response.data);

      if (opportunityResponse.status == true) {
        opportunityResponse.opportunity =
            OpportunityMapper.jsonToEntity(response.data['data']);
      }

      return opportunityResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw OpportunityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Opportunity> getOpportunityById(String id) async {
    try {
      final response =
          await dio.get('/oportunidad/listar-oportunidad-by-id/$id');
      final Opportunity opportunity =
          OpportunityMapper.jsonToEntity(response.data['data']);

      return opportunity;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw OpportunityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Opportunity>> getOpportunities({
    String ruc = '',
    String search = '',
    int offset = 0,
    int limit = 10,
    String idUsuario = '',
  }) async {
    final data = {
      "RUC": ruc,
      "SEARCH": search,
      "OFFSET": offset,
      "TOP": limit,
      "ID_USUARIO_RESPONSABLE": idUsuario
    };
    log(data.toString());
    final response = await dio
        .post('/oportunidad/listar-oportunidades-by-ruc-est', data: data);
    final List<Opportunity> opportunities = [];
    for (final opportunity in response.data['data'] ?? []) {
      opportunities.add(OpportunityMapper.jsonToEntity(opportunity));
    }
    return opportunities;
  }

  @override
  Future<List<Opportunity>> getListOpportunities({
    String ruc = '',
    String search = '',
    int offset = 0,
    int limit = 10,
    String? idUsuario,
    String? estado,
    String? estadoOP,
    String? startDate,
    String? endDate,
    String? startValue,
    String? endValue,
    String? startPercent,
    String? endPercent,
  }) async {
    log("THIS END PERCENT: $endPercent");
    final data = {
      "RUC": ruc,
      "SEARCH": search,
      "OFFSET": offset,
      "TOP": limit,
      "OPRT_ID_ESTADO_OPORTUNIDAD": estadoOP??'', 
      "ID_USUARIO_RESPONSABLE": idUsuario ?? '',
      "ESTADO": estado ?? '',
      "PROBABILIDAD_DESDE": startPercent ?? '',
      "PROBABILIDAD_HASTA": endPercent ?? '',
      "VALOR_DESDE": startValue ?? '',
      "VALOR_HASTA": endValue ?? '',
      "FECHAPREVISTADEVENTA_DESDE": startDate ?? '',
      "FECHAPREVISTADEVENTA_HASTA": endDate ?? ''

    };
    final response = await dio.post(
      '/oportunidad/listar-oportunidades-agrupado-empresa',
      data: data,
    );

    final List<Opportunity> opportunities = [];

    for (final group in response.data['data'] ?? []) {
      final List<dynamic> oportunidadesEnGrupo = group['OPORTUNIDAD'] ?? [];

      if (oportunidadesEnGrupo.isEmpty) continue;

      // Filtrar oportunidades por estado si se especifica
      List<dynamic> oportunidadesFiltradas = oportunidadesEnGrupo;
      if (estado != null && estado.isNotEmpty) {
        final estadosPermitidos = estado.split(',').map((e) => e.trim()).toSet();
        oportunidadesFiltradas = oportunidadesEnGrupo.where((op) {
          final opEstado = op['OPRT_ID_ESTADO_OPORTUNIDAD']?.toString() ?? '';
          return estadosPermitidos.contains(opEstado);
        }).toList();
      }

      // Si después del filtro no quedan oportunidades, saltar este grupo
      if (oportunidadesFiltradas.isEmpty) continue;

      final List<Opportunity> todasLasOportunidades = [];
      for (final opportunityJson in oportunidadesFiltradas) {
        todasLasOportunidades.add(
          OpportunityMapper.jsonToEntity(opportunityJson),
        );
      }

      final primeraOportunidad = todasLasOportunidades[0];
      primeraOportunidad.isFirstInGroup = true;
      primeraOportunidad.oprtPrimeraFechaRegistro =
          group['OPRT_PRIMERA_FECHA_REGISTRO'];
      primeraOportunidad.nombrePrimeroUsuarioResponsable =
          group['NOMBRE_PRIMERO_USUARIO_RESPONSABLE'];
      primeraOportunidad.totalOportunidadesEnGrupo =
          oportunidadesFiltradas.length;
      primeraOportunidad.oportunidadesDelGrupo = todasLasOportunidades;

      opportunities.add(primeraOportunidad);
    }

    return opportunities;
  }

  @override
  Future<List<Opportunity>> getOpportunitiesByName(
      {String ruc = '', String name = ''}) async {
    final data = {"OPRT_RUC": ruc, "OPRT_NOMBRE": name};

    final response = await dio
        .post('/oportunidad/listar-oportunidades-by-nombre', data: data);

    final List<Opportunity> opportunities = [];
    for (final opportunity in response.data['data'] ?? []) {
      opportunities.add(OpportunityMapper.jsonToEntity(opportunity));
    }

    return opportunities;
  }

  @override
  Future<List<Opportunity>> searchOpportunities(
      String ruc, String query) async {
    final data = {"OPRT_NOMBRE": query, "OPRT_RUC": ruc};

    final response = await dio
        .post('/oportunidad/listar-oportunidades-by-nombre', data: data);

    final List<Opportunity> opportunities = [];
    for (final opportunity in response.data['data'] ?? []) {
      opportunities.add(OpportunityMapper.jsonToEntity(opportunity));
    }

    return opportunities;
  }

  @override
  Future<List<StatusOpportunity>> getStatusOpportunityByPeriod() async {
    try {
      final response =
          await dio.post('/oportunidad/listar-estado-oportunidad-by-periodo');

      final List<StatusOpportunity> statusOpportunity = [];
      for (final status in response.data['data'] ?? []) {
        statusOpportunity.add(StatusOpportunityMapper.jsonToEntity(status));
      }

      return statusOpportunity;
    } catch (e) {
      throw Exception();
    }
  }
}

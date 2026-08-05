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

  List<Opportunity> _uniqueOpportunities(List<Opportunity> opportunities) {
    final unique = <Opportunity>[];
    final seenIds = <String>{};

    for (final opportunity in opportunities) {
      if (seenIds.add(opportunity.id)) {
        unique.add(opportunity);
      }
    }

    return unique;
  }

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
  Future<OpportunityResponse> updateOpportunityStatus(
      Map<dynamic, dynamic> payload) async {
    try {
      final response = await dio.post(
        '/oportunidad/actualizar-estado-oportunidad',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return OpportunityResponseMapper.jsonToEntity(response.data);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        return OpportunityResponseMapper.jsonToEntity(
          Map<dynamic, dynamic>.from(responseData),
        );
      }
      if (e.response?.statusCode == 404) throw OpportunityNotFound();
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
    return getListOpportunities(
      ruc: ruc,
      search: search,
      offset: offset,
      limit: limit,
      idUsuario: idUsuario,
      estado: '',
    );
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
    final data = {
      "RUC": ruc,
      "SEARCH": search,
      "OFFSET": offset,
      "TOP": limit,
      "OPRT_ID_ESTADO_OPORTUNIDAD": estadoOP ?? '',
      "ID_USUARIO_RESPONSABLE": idUsuario ?? '',
      "ESTADO": estado ?? '',
      "PROBABILIDAD_DESDE": startPercent ?? '',
      "PROBABILIDAD_HASTA": endPercent ?? '',
      "VALOR_DESDE": startValue ?? '',
      "VALOR_HASTA": endValue ?? '',
      "FECHAPREVISTADEVENTA_DESDE": startDate ?? '',
      "FECHAPREVISTADEVENTA_HASTA": endDate ?? ''
    };

    final activeFilterSnapshot = {
      'SEARCH': search,
      'OFFSET': offset,
      'TOP': limit,
      'ID_USUARIO_RESPONSABLE': idUsuario ?? '',
      'OPRT_ID_ESTADO_OPORTUNIDAD': estadoOP ?? '',
      'ESTADO': estado ?? '',
      'PROBABILIDAD_DESDE': startPercent ?? '',
      'PROBABILIDAD_HASTA': endPercent ?? '',
      'VALOR_DESDE': startValue ?? '',
      'VALOR_HASTA': endValue ?? '',
      'FECHAPREVISTADEVENTA_DESDE': startDate ?? '',
      'FECHAPREVISTADEVENTA_HASTA': endDate ?? '',
    };

    final response = await dio.post(
      '/oportunidad/listar-oportunidades-agrupado-empresa',
      data: data,
    );

    final Map<String, Opportunity> groupedOpportunities = {};
    final bool isActivosRequest = (estado ?? '').trim() == '01,02,03,04';
    final bool isEnPausaRequest = (estado ?? '').trim() == '05';

    for (final group in response.data['data'] ?? []) {
      final List<dynamic> oportunidadesEnGrupo = group['OPORTUNIDAD'] ?? [];

      if (oportunidadesEnGrupo.isEmpty) continue;

      final List<Opportunity> oportunidadesParseadas = [];
      for (final opportunityJson in oportunidadesEnGrupo) {
        try {
          oportunidadesParseadas.add(
            OpportunityMapper.jsonToEntity(opportunityJson),
          );
        } catch (e) {
          log(
            'OPPORTUNITY PARSE ERROR (grupoCompleto) id=${opportunityJson['OPRT_ID_OPORTUNIDAD']} '
            'fechaPrevista=${opportunityJson['OPRT_FECHA_PREVISTA_VENTA']} '
            'fechaRegistro=${opportunityJson['OPRT_FECHA_REGISTRO']} error=$e',
          );
        }
      }

      if (oportunidadesParseadas.isEmpty) continue;

      // A partir de aqui se confia en backend como fuente de verdad. El
      // servicio agrupado ya debe devolver `OPORTUNIDAD` segun los parametros
      // enviados (ESTADO, filtros, busqueda, etc.), por lo que frontend no
      // vuelve a filtrar localmente por estado/valor/probabilidad/fecha.

      final primeraOportunidad = oportunidadesParseadas[0];
      final empresaKey =
          '${primeraOportunidad.oprtRuc ?? ''}-${primeraOportunidad.oprtLocalCodigo ?? ''}';
      final existing = groupedOpportunities[empresaKey];

      if (existing == null) {
        primeraOportunidad.isFirstInGroup = true;
        primeraOportunidad.oprtPrimeraFechaRegistro =
            group['OPRT_PRIMERA_FECHA_REGISTRO'];
        primeraOportunidad.nombrePrimeroUsuarioResponsable =
            group['NOMBRE_PRIMERO_USUARIO_RESPONSABLE'];
        primeraOportunidad.oportunidadesDelGrupo =
            _uniqueOpportunities(oportunidadesParseadas);
        primeraOportunidad.visibleOportunidadesDelGrupo =
            _uniqueOpportunities(oportunidadesParseadas);
        primeraOportunidad.totalOportunidadesEnGrupo =
            primeraOportunidad.oportunidadesDelGrupo!.length;

        groupedOpportunities[empresaKey] = primeraOportunidad;
        continue;
      }

      existing.oportunidadesDelGrupo = _uniqueOpportunities([
        ...(existing.oportunidadesDelGrupo ?? []),
        ...oportunidadesParseadas,
      ]);
      existing.visibleOportunidadesDelGrupo = _uniqueOpportunities([
        ...(existing.visibleOportunidadesDelGrupo ?? []),
        ...oportunidadesParseadas,
      ]);
      existing.totalOportunidadesEnGrupo =
          existing.oportunidadesDelGrupo?.length ?? 0;
    }

    final result = groupedOpportunities.values.toList();

    if (isActivosRequest || isEnPausaRequest) {
      final rawGroups = (response.data['data'] as List? ?? []).length;
      final rawStates = <String, int>{};
      final rawValues = <String>[];
      final rawDates = <String>[];
      for (final group in response.data['data'] ?? []) {
        for (final opportunityJson in group['OPORTUNIDAD'] ?? []) {
          final state =
              (opportunityJson['OPRT_ID_ESTADO_OPORTUNIDAD'] ?? '').toString();
          rawStates[state] = (rawStates[state] ?? 0) + 1;
          rawValues.add(
            '${opportunityJson['OPRT_ID_OPORTUNIDAD']}:${opportunityJson['OPRT_VALOR']}',
          );
          rawDates.add(
            '${opportunityJson['OPRT_ID_OPORTUNIDAD']}:${opportunityJson['OPRT_FECHA_PREVISTA_VENTA']}',
          );
        }
      }

      final finalIds = result
          .map(
            (group) =>
                '${group.razon} -> ${(group.visibleOportunidadesDelGrupo ?? group.oportunidadesDelGrupo ?? []).map((op) => op.id).join(",")}',
          )
          .join(' | ');

      log(
        '${isActivosRequest ? 'ACTIVOS' : 'EN_PAUSA'} CHECK => requestEstado=${estado ?? ''}, rawGroups=$rawGroups, rawStates=$rawStates, finalGroups=${result.length}, finalVisible=$finalIds',
      );

      if (isActivosRequest) {
        log(
          'ACTIVOS FILTER REQUEST => $activeFilterSnapshot',
        );
        log(
          'ACTIVOS FILTER RESPONSE => rawValues=$rawValues, rawDates=$rawDates',
        );
      }
    }

    return result;
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

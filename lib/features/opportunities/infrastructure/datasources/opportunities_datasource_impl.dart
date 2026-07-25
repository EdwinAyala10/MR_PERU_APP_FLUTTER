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
    final response = await dio.post(
      '/oportunidad/listar-oportunidades-agrupado-empresa',
      data: data,
    );

    final List<Opportunity> opportunities = [];

    for (final group in response.data['data'] ?? []) {
      final List<dynamic> oportunidadesEnGrupo = group['OPORTUNIDAD'] ?? [];

      if (oportunidadesEnGrupo.isEmpty) continue;

      // Se conserva SIEMPRE el grupo completo de empresa en memoria para que
      // el detalle navegue con todas las oportunidades, aunque la lista
      // visible esté filtrada por estado/fecha/probabilidad/etc.
      final List<Opportunity> grupoCompleto = [];
      for (final opportunityJson in oportunidadesEnGrupo) {
        grupoCompleto.add(
          OpportunityMapper.jsonToEntity(opportunityJson),
        );
      }

      // Filtrar oportunidades por estado si se especifica
      List<dynamic> oportunidadesFiltradas = oportunidadesEnGrupo;
      if (estado != null && estado.isNotEmpty) {
        final estadosPermitidos =
            estado.split(',').map((e) => e.trim()).toSet();
        oportunidadesFiltradas = oportunidadesEnGrupo.where((op) {
          final opEstado = op['OPRT_ID_ESTADO_OPORTUNIDAD']?.toString() ?? '';
          return estadosPermitidos.contains(opEstado);
        }).toList();
      }

      if (estadoOP != null && estadoOP.isNotEmpty) {
        final estadosOportunidad =
            estadoOP.split(',').map((e) => e.trim()).toSet();
        oportunidadesFiltradas = oportunidadesFiltradas.where((op) {
          final opEstado = op['OPRT_ID_ESTADO_OPORTUNIDAD']?.toString() ?? '';
          return estadosOportunidad.contains(opEstado);
        }).toList();
      }

      final probDesde = double.tryParse((startPercent ?? '').trim());
      final probHasta = double.tryParse((endPercent ?? '').trim());
      if (probDesde != null || probHasta != null) {
        oportunidadesFiltradas = oportunidadesFiltradas.where((op) {
          final prob =
              double.tryParse((op['OPRT_PROBABILIDAD'] ?? '').toString()) ?? 0;
          if (probDesde != null && prob < probDesde) return false;
          if (probHasta != null && prob > probHasta) return false;
          return true;
        }).toList();
      }

      final valorDesde = double.tryParse((startValue ?? '').trim()) ?? 0;
      final valorHasta = double.tryParse((endValue ?? '').trim()) ?? 0;
      if (valorDesde > 0 || valorHasta > 0) {
        oportunidadesFiltradas = oportunidadesFiltradas.where((op) {
          final valor =
              double.tryParse((op['OPRT_VALOR'] ?? '').toString()) ?? 0;
          if (valorDesde > 0 && valor < valorDesde) return false;
          if (valorHasta > 0 && valor > valorHasta) return false;
          return true;
        }).toList();
      }

      final fechaDesde = DateTime.tryParse((startDate ?? '').trim());
      final fechaHasta = DateTime.tryParse((endDate ?? '').trim());
      if (fechaDesde != null || fechaHasta != null) {
        oportunidadesFiltradas = oportunidadesFiltradas.where((op) {
          final rawFecha = (op['OPRT_FECHA_PREVISTA_VENTA'] ?? '').toString();
          final fecha = DateTime.tryParse(rawFecha);
          if (fecha == null) return false;
          if (fechaDesde != null && fecha.isBefore(fechaDesde)) return false;
          if (fechaHasta != null && fecha.isAfter(fechaHasta)) return false;
          return true;
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
      primeraOportunidad.totalOportunidadesEnGrupo = grupoCompleto.length;
      primeraOportunidad.oportunidadesDelGrupo = grupoCompleto;
      primeraOportunidad.visibleOportunidadesDelGrupo = todasLasOportunidades;

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

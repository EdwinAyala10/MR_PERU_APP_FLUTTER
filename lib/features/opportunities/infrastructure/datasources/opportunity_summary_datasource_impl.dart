import 'package:dio/dio.dart';
import '../../domain/datasources/opportunity_summary_datasource.dart';
import '../../domain/entities/opportunity_summary.dart';
import '../mappers/opportunity_summary_mapper.dart';

class OpportunitySummaryDatasourceImpl extends OpportunitySummaryDatasource {
  final Dio dio;

  OpportunitySummaryDatasourceImpl({required this.dio});

  @override
  Future<OpportunitySummary> generateSummary(String opportunityId) async {
    try {
      final response = await dio.get(
        '/oportunidad/generar-resumen-por-id/$opportunityId',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception('Error ${response.statusCode}: No se pudo generar el resumen');
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return OpportunitySummaryMapper.fromJson(data);
      }

      throw Exception('Respuesta inválida del servidor');
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return OpportunitySummaryMapper.fromJson(e.response!.data);
      }
      throw Exception(e.message ?? 'Error de conexión al generar resumen');
    }
  }
}

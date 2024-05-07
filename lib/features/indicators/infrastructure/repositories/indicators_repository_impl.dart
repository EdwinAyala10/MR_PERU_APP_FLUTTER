import 'package:crm_app/features/indicators/domain/domain.dart';

class IndicatorsRepositoryImpl extends IndicatorsRepository {

  final IndicatorsDatasource datasource;

  IndicatorsRepositoryImpl(this.datasource);

  @override
  Future<IndicatorResponse> sendIndicators(Map<dynamic, dynamic> params) {
    return datasource.sendIndicators(params);
  }

}
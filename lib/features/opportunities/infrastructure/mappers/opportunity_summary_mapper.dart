import '../../domain/entities/opportunity_summary.dart';

class OpportunitySummaryMapper {
  static OpportunitySummary fromJson(Map<String, dynamic> json) {
    return OpportunitySummary(
      type: json['type']?.toString() ?? 'full',
      icon: json['icon']?.toString() ?? 'info',
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data']?.toString() ?? '',
    );
  }
}

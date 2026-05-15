class OpportunitySummary {
  final String type;
  final String icon;
  final bool status;
  final String message;
  final String data;

  const OpportunitySummary({
    required this.type,
    required this.icon,
    required this.status,
    required this.message,
    required this.data,
  });

  bool get isSuccess => status;
  bool get hasData => data.isNotEmpty;
}

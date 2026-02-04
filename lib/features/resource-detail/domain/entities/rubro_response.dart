import '../domain.dart';

class RubroResponse {
  String type;
  String icon;
  bool status;
  String message;
  ResourceDetail? resourceDetail;

  RubroResponse({
    required this.type,
    required this.icon,
    required this.status,
    required this.message,
    this.resourceDetail,
  });
}

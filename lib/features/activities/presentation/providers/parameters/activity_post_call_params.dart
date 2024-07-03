import 'package:equatable/equatable.dart';

class ActivityPostCallParams extends Equatable  {
  const ActivityPostCallParams({
    required this.contactId,
    required this.phone,
  });

  final String contactId;
  final String phone;

  @override
  List<Object> get props => [contactId, phone];
}
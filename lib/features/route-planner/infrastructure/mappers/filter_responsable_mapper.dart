import '../../domain/domain.dart';


class FilterResposanbleMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => FilterResponsable(
    id: json['ID'] ?? '',
    userreportCodigo: json['USERREPORT_CODIGO'] ?? '',
    userreportEmail: json['USERREPORT_EMAIL'] ?? '',
    userreportName: json['USERREPORT_NAME'] ?? '',
    userreportType: json['USERREPORT_TYPE'] ?? '',
    userreportAbbrt: json['USERREPORT_ABBRT'] ?? '',
  );

}

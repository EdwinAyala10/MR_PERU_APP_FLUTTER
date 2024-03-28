import 'package:crm_app/features/contacts/domain/domain.dart';


class ContactMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Contact(
    id: json['CONTACTO_ID'] ?? '',
    ruc: json['RUC'] ?? '',
    razon: json['RAZON'] ?? '',
    contactoTitulo: json['CONTACTO_TITULO'] ?? '',
    contactoDesc: json['CONTACTO_DESC'] ?? '',
    contactoCargo: json['CONTACTO_CARGO'] ?? '',
    contactoEmail: json['CONTACTO_EMAIL'] ?? '',
    contactoTelefonoc: json['CONTACTO_TELEFONOC'] ?? '',
    contactoTelefonof: json['CONTACTO_TELEFONOF'] ?? '',
    contactoFax: json['CONTACTO_FAX'] ?? '',
    contactoNotas: json['CONTACTO_NOTAS'] ?? '',
    contactoIdCargo: json['CONTACTO_ID_CARGO'] ?? '',
    contactoNombreCargo: json['CONTACTO_NOMBRE_CARGO'] ?? '',
    opt: json['OPT'] ?? '',
    contactIdIn: json['CONTACTO_ID'] ?? '',
  );

}

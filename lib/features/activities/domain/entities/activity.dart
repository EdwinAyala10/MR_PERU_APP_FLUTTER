import 'package:crm_app/features/contacts/domain/domain.dart';

class Activity {
  String id;
  String actiIdUsuarioResponsable;
  String actiIdTipoGestion;
  DateTime actiFechaActividad;
  String actiHoraActividad;
  String actiRuc;
  String? actiRazon;
  String actiIdOportunidad;
  String actiIdContacto;
  String actiComentario;
  String actiNombreArchivo;
  String actiIdUsuarioRegistro;
  String actiEstadoReg;
  String actiNombreTipoGestion;
  String actiNombreOportunidad;
  String? actiIdUsuarioActualizacion;
  String? opt;
  String? actiIdActividadIn;
  String? actiNombreResponsable;
  List<ContactArray>? actividadesContacto;
  List<ContactArray>? actividadesContactoEliminar;

  Activity(
      {required this.id,
      required this.actiIdUsuarioResponsable,
      required this.actiIdTipoGestion,
      required this.actiFechaActividad,
      required this.actiHoraActividad,
      required this.actiRuc,
      required this.actiIdOportunidad,
      required this.actiIdContacto,
      required this.actiComentario,
      required this.actiNombreArchivo,
      required this.actiIdUsuarioRegistro,
      required this.actiEstadoReg,
      required this.actiNombreTipoGestion,
      required this.actiNombreOportunidad,
      this.actiIdUsuarioActualizacion,
      this.actiIdActividadIn,
      this.opt,
      this.actividadesContacto,
      this.actividadesContactoEliminar,
      this.actiRazon,
      this.actiNombreResponsable});
}

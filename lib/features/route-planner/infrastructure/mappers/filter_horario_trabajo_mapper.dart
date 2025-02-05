import '../../domain/domain.dart';


class FilterHorarioTrabajoMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => FilterHorarioTrabajo(
    hrtrIdHorarioTrabajo: json['HRTR_ID_HORARIO_TRABAJO'] ?? '',
    hrtrCodigo: json['HRTR_CODIGO'] ?? '',
    hrtrDescricion: json['HRTR_DESCRIPCION'] ?? '',
    hrtrTiempoEntreVisita: json['HRTR_TIEMPO_ENTRE_VISITA'] ?? '',
    hrtrTiempoDeVisita: json['HRTR_TIEMPO_DE_VISITA'] ?? '',
    hrtrHoraInicioLunVie: json['HRTR_HORA_INICIO_LUN_VIE'] ?? '',
    hrtrHoraInicioSab: json['HRTR_HORA_INICIO_SAB'] ?? '',
    hrtrTotalRegistroLunVie: json['HRTR_TOTAL_REGISTRO_LUN_VIE'] ?? '',
    hrtrTotalRegistroSab: json['HRTR_TOTAL_REGISTRO_SAB'] ?? '',
    hrtrIdUsuarioRegistro: json['HRTR_ID_USUARIO_REGISTRO'] ?? '',
    hrtrVisible: json['HRTR_VISIBLE'] ?? '',
    hrtrOrden: json['HRTR_ORDEN'] ?? '',
  );

}

import 'package:crm_app/features/route-planner/domain/entities/validar_horario_trabajo.dart';

class ValidarHorarioTrabajoMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ValidarHorarioTrabajo(
    idHorarioTrabajo: json['HRTR_ID_HORARIO_TRABAJO'] ?? '',
    codigo: json['HRTR_CODIGO'] ?? '',
    descripcion: json['HRTR_DESCRIPCION'] ?? '',
    tiempoEntreVisita: json['HRTR_TIEMPO_ENTRE_VISITA'] ?? '',
    tiempoDeVisita: json['HRTR_TIEMPO_DE_VISITA'] ?? '',
    horaInicioLunVie: json['HRTR_HORA_INICIO_LUN_VIE'] ?? '',
    horaInicioSab: json['HRTR_HORA_INICIO_SAB'] ?? '',
    totalRegistroLunVie: json['HRTR_TOTAL_REGISTRO_LUN_VIE'] ?? '',
    totalRegistroSab: json['HRTR_TOTAL_REGISTRO_SAB'] ?? '',
    idUsuarioRegistro: json['HRTR_ID_USUARIO_REGISTRO'] ?? '',
  );

}

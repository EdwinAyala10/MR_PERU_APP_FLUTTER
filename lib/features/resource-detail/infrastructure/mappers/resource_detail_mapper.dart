import '../../domain/domain.dart';

class ResourceDetailMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ResourceDetail(
    recdIdRecursos: json['RECD_ID_RECURSOS'] ?? '', 
    recdGrupo: json['RECD_GRUPO'] ?? '', 
    recdCodigo: json['RECD_CODIGO'] ?? '', 
    recdNombre: json['RECD_NOMBRE'] ?? '', 
    recdNombreCorto: json['RECD_NOMBRE_CORTO'] ?? '', 
    recdNombreTabla: json['RECD_NOMBRE_TABLA'] ?? '', 
    recdOrden: json['RECD_ORDEN'] ?? '', 
    recdSimbolo: json['RECD_SIMBOLO'] ?? '', 
    recdColorTexto: json['RECD_COLOR_TEXTO'] ?? '', 
    recdIcono: json['RECD_ICONO'] ?? '', 
    recdIconoTexto: json['RECD_ICONO_TEXTO'] ?? '', 
    recdParentIdRecursos: json['RECD_PARENT_ID_RECURSOS'] ?? '', 
    recdEstadoReg: json['RECD_ESTADO_REG'] ?? '', 
  );

}

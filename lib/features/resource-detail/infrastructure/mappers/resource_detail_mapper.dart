import 'package:crm_app/features/resource-detail/domain/domain.dart';

class ResourceDetailMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => ResourceDetail(
    recdIdRecursos: json['data']['RECD_ID_RECURSOS'], 
    recdGrupo: json['data']['RECD_GRUPO'], 
    recdCodigo: json['data']['RECD_CODIGO'], 
    recdNombre: json['data']['RECD_NOMBRE'], 
    recdNombreCorto: json['data']['RECD_NOMBRE_CORTO'], 
    recdNombreTabla: json['data']['RECD_NOMBRE_TABLA'], 
    recdOrden: json['data']['RECD_ORDEN'], 
    recdSimbolo: json['data']['RECD_SIMBOLO'], 
    recdColorTexto: json['data']['RECD_COLOR_TEXTO'], 
    recdIcono: json['data']['RECD_ICONO'], 
    recdIconoTexto: json['data']['RECD_ICONO_TEXTO'], 
    recdParentIdRecursos: json['data']['RECD_PARENT_ID_RECURSOS'], 
    recdEstadoReg: json['data']['RECD_ESTADO_REG'], 
  );

}

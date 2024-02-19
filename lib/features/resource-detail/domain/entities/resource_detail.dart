import 'dart:convert';

ResourceDetail resourceDetailFromJson(String str) => ResourceDetail.fromJson(json.decode(str));

String resourceDetailToJson(ResourceDetail data) => json.encode(data.toJson());

class ResourceDetail {
    String recdIdRecursos;
    String recdGrupo;
    String recdCodigo;
    String recdNombre;
    dynamic recdNombreCorto;
    String recdNombreTabla;
    String recdOrden;
    dynamic recdSimbolo;
    dynamic recdColorTexto;
    dynamic recdIcono;
    dynamic recdIconoTexto;
    String recdParentIdRecursos;
    String recdEstadoReg;

    ResourceDetail({
        required this.recdIdRecursos,
        required this.recdGrupo,
        required this.recdCodigo,
        required this.recdNombre,
        required this.recdNombreCorto,
        required this.recdNombreTabla,
        required this.recdOrden,
        required this.recdSimbolo,
        required this.recdColorTexto,
        required this.recdIcono,
        required this.recdIconoTexto,
        required this.recdParentIdRecursos,
        required this.recdEstadoReg,
    });

    factory ResourceDetail.fromJson(Map<String, dynamic> json) => ResourceDetail(
        recdIdRecursos: json["RECD_ID_RECURSOS"],
        recdGrupo: json["RECD_GRUPO"],
        recdCodigo: json["RECD_CODIGO"],
        recdNombre: json["RECD_NOMBRE"],
        recdNombreCorto: json["RECD_NOMBRE_CORTO"],
        recdNombreTabla: json["RECD_NOMBRE_TABLA"],
        recdOrden: json["RECD_ORDEN"],
        recdSimbolo: json["RECD_SIMBOLO"],
        recdColorTexto: json["RECD_COLOR_TEXTO"],
        recdIcono: json["RECD_ICONO"],
        recdIconoTexto: json["RECD_ICONO_TEXTO"],
        recdParentIdRecursos: json["RECD_PARENT_ID_RECURSOS"],
        recdEstadoReg: json["RECD_ESTADO_REG"],
    );

    Map<String, dynamic> toJson() => {
        "RECD_ID_RECURSOS": recdIdRecursos,
        "RECD_GRUPO": recdGrupo,
        "RECD_CODIGO": recdCodigo,
        "RECD_NOMBRE": recdNombre,
        "RECD_NOMBRE_CORTO": recdNombreCorto,
        "RECD_NOMBRE_TABLA": recdNombreTabla,
        "RECD_ORDEN": recdOrden,
        "RECD_SIMBOLO": recdSimbolo,
        "RECD_COLOR_TEXTO": recdColorTexto,
        "RECD_ICONO": recdIcono,
        "RECD_ICONO_TEXTO": recdIconoTexto,
        "RECD_PARENT_ID_RECURSOS": recdParentIdRecursos,
        "RECD_ESTADO_REG": recdEstadoReg,
    };
}

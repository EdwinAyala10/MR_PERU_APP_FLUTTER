import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/domain/entities/array_user.dart';
import 'package:crm_app/features/kpis/domain/entities/periodicidad.dart';

class Kpi {
    String id;
    String objrNombre;
    String objrIdUsuarioResponsable;
    String? objrNombreUsuarioResponsable;
    String objrIdAsignacion;
    String? objrNombreAsignacion;
    String objrIdTipo;
    String? objrNombreTipo;
    String objrIdPeriodicidad;
    String? objrNombrePeriodicidad;
    String? objrObservaciones;
    String objrIdUsuarioRegistro;
    String? objrNombreUsuarioRegistro;
    String objrIdCategoria;
    String? objrCantidad;
    String? objrNombreCategoria;
    int? totalRegistro;
    int? porcentaje;
    bool? objrValorDifMes;
    List<ArrayUser>? arrayuserasignacion;
    List<Periodicidad>? peobIdPeriodicidad;
    List<UsuarioAsignado>? usuariosAsignados;

    Kpi({
        required this.id,
        required this.objrNombre,
        required this.objrIdUsuarioResponsable,
        required this.objrIdAsignacion,
        required this.objrIdTipo,
        required this.objrIdPeriodicidad,
        required this.objrIdUsuarioRegistro,
        required this.objrIdCategoria,
        this.objrNombreCategoria,
        this.objrObservaciones,
        this.objrNombreAsignacion,
        this.objrNombrePeriodicidad,
        this.objrNombreTipo,
        this.objrCantidad,
        this.objrNombreUsuarioResponsable,
        this.objrNombreUsuarioRegistro,
        this.arrayuserasignacion,
        this.peobIdPeriodicidad,
        this.totalRegistro,
        this.porcentaje,
        this.objrValorDifMes,
        this.usuariosAsignados,
    });
}

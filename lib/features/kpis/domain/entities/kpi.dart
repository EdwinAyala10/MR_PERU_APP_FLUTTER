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
    String? objrNombreCategoria;

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
        this.objrNombreUsuarioResponsable,
        this.objrNombreUsuarioRegistro
    });
}

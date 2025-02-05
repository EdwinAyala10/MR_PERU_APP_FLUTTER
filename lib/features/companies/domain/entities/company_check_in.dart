class CompanyCheckIn {
    String cchkIdClientesCheck;
    String cchkRuc;
    String? cchkRazon;
    String cchkIdOportunidad;
    String cchkNombreOportunidad;
    String cchkIdContacto;
    String cchkNombreContacto;
    String cchkIdEstadoCheck;
    String cchkIdComentario;
    String cchkIdUsuarioResponsable;
    String? cchkNombreUsuarioResponsable;
    String? cchkUbigeo;
    String? cchkCoordenadaLatitud;
    String? cchkCoordenadaLongitud;
    String? cchkDireccionMapa;
    String? cchkIdUsuarioRegistro;
    String cchkLocalCodigo;
    String? cchkLocalNombre;
    String? cchkVisitaFrioCaliente;
    String? cchkIdTipoVista;
    String? cchkNombreTipoVisita;

    CompanyCheckIn({
        required this.cchkIdClientesCheck,
        required this.cchkRuc,
        required this.cchkIdOportunidad,
        required this.cchkNombreOportunidad,
        required this.cchkIdContacto,
        required this.cchkNombreContacto,
        required this.cchkIdEstadoCheck,
        required this.cchkIdComentario,
        required this.cchkIdUsuarioResponsable,
        required this.cchkLocalCodigo,
        this.cchkNombreUsuarioResponsable,
        this.cchkRazon,
        this.cchkUbigeo,
        this.cchkCoordenadaLatitud,
        this.cchkCoordenadaLongitud,
        this.cchkDireccionMapa,
        this.cchkIdUsuarioRegistro,
        this.cchkLocalNombre,
        this.cchkVisitaFrioCaliente,
        this.cchkIdTipoVista,
        this.cchkNombreTipoVisita
    });

}


class Contact {
    String id;
    String ruc;
    String? razon;
    String contactoTitulo;
    String contactoDesc;
    String contactoCargo;
    String? contactoEmail;
    String contactoTelefonof;
    String? contactoTelefonoc;
    String? contactoFax;
    String? opt;
    String? contactIdIn;
    String? contactoIdCargo;
    String? contactoNombreCargo;
    String? contactoNotas;

    Contact({
        required this.id,
        required this.ruc,
        required this.contactoTitulo,
        required this.contactoDesc,
        required this.contactoCargo,
        required this.contactoTelefonof,
        this.contactoEmail,
        this.opt,
        this.razon,
        this.contactIdIn,
        this.contactoTelefonoc,
        this.contactoFax,
        this.contactoNotas,
        this.contactoIdCargo,
        this.contactoNombreCargo,
    });
}

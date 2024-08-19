class DocumentOpportunitie {
  String adjtIdAdjunto;
  String adjtTipoRegistro;
  String adjtNombreArchivo;
  String? adjtTipoArchivo;
  String adjtNombreOriginal;
  String adjtRutalRelativa;
  String adjtEstado;
  String adjtIdTipoRegistro;
  List<String>? documents;
  String? document;
  String? path;
  String? filename;
  String? adjtEnlace;

  DocumentOpportunitie({
    required this.adjtIdAdjunto,
    required this.adjtTipoRegistro,
    required this.adjtNombreArchivo,
    required this.adjtNombreOriginal,
    required this.adjtIdTipoRegistro,
    required this.adjtRutalRelativa,
    required this.adjtEstado,
    this.adjtTipoArchivo,
    this.documents,
    this.document,
    this.path,
    this.filename,
    this.adjtEnlace,
  });
}

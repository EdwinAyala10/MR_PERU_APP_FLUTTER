import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/documents/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class DocumentCard extends StatelessWidget {

  final Document document;

  const DocumentCard({
    super.key, 
    required this.document
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.27),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          document.adjtIdTipoRegistro == '01' 
           ? SizedBox(width: 60, height: 60, child: _ImageViewer(image: '${Environment.urlPublic}${document.adjtRutalRelativa}' ))
           : _IconViewer( document: document ),
          const SizedBox(
            width: 14,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                document.adjtIdTipoRegistro == '01' ? 'Documento' : 'Enlace', 
                style: const TextStyle(
                  fontWeight: FontWeight.w700
              )),
              SizedBox(
                width: 200,
                child: Text(
                  document.adjtIdTipoRegistro == '01' ? document.adjtNombreOriginal : document.adjtEnlace ?? '', 
                  textAlign: TextAlign.start, 
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}

class _IconViewer extends StatelessWidget {
  final Document document;

  const _IconViewer({required this.document});

  @override
  Widget build(BuildContext context) {

    IconData icono;
    Color? color;

    switch (document.adjtTipoArchivo) {
      case 'pdf':
        icono = FontAwesomeIcons.filePdf;
        color = Colors.red[400];
        break;
      case 'txt':
        icono = FontAwesomeIcons.fileLines;
        color = Colors.black87;
        break;
      case 'doc':
      case 'docx':
      case 'odt':
        icono = FontAwesomeIcons.fileWord;
        color = Colors.blue;
        break;
      case 'xls':
      case 'xlsx':
      case 'ods':
      case 'csv':
        icono = FontAwesomeIcons.fileExcel;
        color = Colors.green;
        break;
      case 'ppt':
      case 'pptx':
      case 'odp':
        icono = FontAwesomeIcons.filePowerpoint;
        color = Colors.orange;
        break;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
        icono = FontAwesomeIcons.fileAudio;
        color = Colors.orange;
        break;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
        icono = FontAwesomeIcons.fileVideo;
        color = Colors.orange;
        break;
      case 'zip':
      case 'rar':
      case 'tar':
      case 'gz':
      case '7z':
        icono = FontAwesomeIcons.fileZipper;
        color = Colors.black54;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'bmp':
      case 'tiff':
      case 'svg':
      case 'gif':
        icono = FontAwesomeIcons.fileImage;
        color = Colors.black54;
        break;
      default:
        icono = FontAwesomeIcons.file;
        color = Colors.black;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: FaIcon(
        icono, 
        color: color, 
        size: 60,
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {

  final String image;

  const _ImageViewer({ required this.image });

  @override
  Widget build(BuildContext context) {
    
    if ( image.isEmpty ) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/images/no-image.jpg', 
          fit: BoxFit.cover,
          width: 100,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: FadeInImage(
        fit: BoxFit.cover,
        width: 100,
        fadeOutDuration: const Duration(milliseconds: 100),
        fadeInDuration: const Duration(milliseconds: 200),
        image: NetworkImage( image ),
        placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
      ),
    );

  }
}
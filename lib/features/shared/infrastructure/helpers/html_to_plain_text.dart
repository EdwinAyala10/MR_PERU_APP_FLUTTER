import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

/// Convierte HTML a texto plano manteniendo estructura básica
class HtmlToPlainText {
  /// Convierte HTML a texto plano
  static String convert(String htmlString) {
    if (htmlString.isEmpty) return '';
    
    try {
      // Parse HTML
      final document = html_parser.parse(htmlString);
      
      // Extraer texto con formato básico
      return _extractText(document.body);
    } catch (e) {
      // Si falla el parsing, devolver el string original sin tags
      return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    }
  }
  
  static String _extractText(dom.Element? element) {
    if (element == null) return '';
    
    final buffer = StringBuffer();
    
    for (var node in element.nodes) {
      if (node is dom.Text) {
        buffer.write(node.text);
      } else if (node is dom.Element) {
        switch (node.localName) {
          case 'br':
            buffer.write('\n');
            break;
          case 'p':
            buffer.write(_extractText(node));
            buffer.write('\n\n');
            break;
          case 'div':
            buffer.write(_extractText(node));
            buffer.write('\n');
            break;
          case 'li':
            buffer.write('• ');
            buffer.write(_extractText(node));
            buffer.write('\n');
            break;
          case 'strong':
          case 'b':
            buffer.write(_extractText(node));
            break;
          case 'em':
          case 'i':
            buffer.write(_extractText(node));
            break;
          case 'u':
            buffer.write(_extractText(node));
            break;
          case 'a':
            final href = node.attributes['href'];
            buffer.write(_extractText(node));
            if (href != null && href.isNotEmpty) {
              buffer.write(' ($href)');
            }
            break;
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            buffer.write(_extractText(node));
            buffer.write('\n\n');
            break;
          default:
            buffer.write(_extractText(node));
        }
      }
    }
    
    return buffer.toString();
  }
}

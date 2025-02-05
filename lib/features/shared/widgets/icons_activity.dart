import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconsActivity extends StatelessWidget {
  String type;
  double size;

  IconsActivity({super.key, required this.type, this.size = 36.0});

  @override
  Widget build(BuildContext context) {

    IconData icono;
    Color color;

    switch (type) {
      case '01':
        icono = Icons.comment;
        color = Colors.blue;
        break;
      case '02':
        icono = Icons.call;
        color = Colors.green;
        break;
      case '03':
        icono = Icons.people;
        color = Colors.orange;
        break;
      case '04':
        icono = Icons.location_on;
        color = Colors.red;
        break;
      case '05':
        icono = Icons.chat;
        color = Colors.green;
        break;
      case '06':
        icono = Icons.phone_forwarded;
        color = Colors.orangeAccent;
        break;
      default:
        icono = Icons.view_kanban_outlined;
        color = Colors.black;
        break;
    }

    return type == '05' 
    ? FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: size) 
    : Icon(
      //Icons.airline_stops_sharp
      icono, 
      size: size,
      color: color,
    );
  }
}
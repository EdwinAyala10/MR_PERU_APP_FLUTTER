import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:flutter/material.dart';

class SelectCustomForm extends StatelessWidget {
  String label;
  String value;
  Function(String?)? callbackChange;
  List<DropdownOption> items;

  SelectCustomForm(
      {super.key,
      required this.label,
      required this.value,
      required this.callbackChange,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 220,
            child: DropdownButton<String>(
              value: value,
              onChanged: callbackChange,
              isExpanded: true,
              iconSize: 30.0,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
              underline: Container(
                height: 2,
                color: Color.fromARGB(255, 43, 140, 164), // Cambia el color de la línea seleccionada
              ),
              items: items.map((option) {
                return DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(
                    option.name,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

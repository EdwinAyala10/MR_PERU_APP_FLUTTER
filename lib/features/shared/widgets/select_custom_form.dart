import 'package:flutter/material.dart';
import '../domain/entities/dropdown_option.dart';

class SelectCustomForm extends StatelessWidget {
  final String label;
  final String value;
  final Function(String?)? callbackChange;
  final List<DropdownOption> items;
  final String? errorMessage;
  final bool isDisabled; // Parámetro opcional

  const SelectCustomForm({
    Key? key,
    required this.label,
    required this.value,
    required this.callbackChange,
    required this.items,
    this.errorMessage,
    this.isDisabled = false, // Valor predeterminado es false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String selectedValue = value;
    if (!items.any((item) => item.id == value)) {
      // Si no existe, usar el primer elemento de la lista como valor predeterminado
      selectedValue = items.isNotEmpty ? items.first.id : '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: errorMessage == null ? Colors.black : Colors.red[400],
                ),
              ),
            ),
          const SizedBox(
            height: 6,
          ),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              onChanged: isDisabled ? null : callbackChange, // Deshabilitar si isDisabled es true
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 30.0,
              style: const TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                ),
                errorText: errorMessage,
                enabled: !isDisabled, // Cambiar estado del InputDecoration si está deshabilitado
              ),
              items: items.map((option) {
                return DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 15.0, 
                      color: errorMessage == null ? Colors.black : Colors.red[400]
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(
            height: 2.0,
          ),
        ],
      ),
    );
  }
}
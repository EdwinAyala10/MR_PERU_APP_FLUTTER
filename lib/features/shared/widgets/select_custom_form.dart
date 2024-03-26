import 'package:flutter/material.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';

class SelectCustomForm extends StatelessWidget {
  final String label;
  final String value;
  final Function(String?)? callbackChange;
  final List<DropdownOption> items;
  final String? errorMessage;

  const SelectCustomForm({
    Key? key,
    required this.label,
    required this.value,
    required this.callbackChange,
    required this.items,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          const SizedBox(
            height: 6,
          ),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: value,
              onChanged: callbackChange,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 30.0,
              style: const TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
              ),
              items: items.map((option) {
                return DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(
                    option.name,
                    style: const TextStyle(fontSize: 15.0),
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

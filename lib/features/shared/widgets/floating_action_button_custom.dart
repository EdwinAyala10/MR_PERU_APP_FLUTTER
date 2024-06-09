import 'package:crm_app/config/config.dart';
import 'package:flutter/material.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  IconData iconData;
  Function()? callOnPressed;
  bool? isDisabled;
  FloatingActionButtonCustom(
      {super.key,
      required this.callOnPressed,
      required this.iconData,
      this.isDisabled});

  @override
  Widget build(BuildContext context) {
    bool styleDisabled = isDisabled ?? false;
    return SizedBox(
      width: 46+ 9.0 * 2,
      height: 46 + 9.0 * 2,
      child: FloatingActionButton(
        onPressed: callOnPressed,
        backgroundColor: styleDisabled
            ? const Color.fromARGB(255, 155, 155, 155)
            :  primaryColor,
        shape: const CircleBorder(),
        child: Icon(
          iconData,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'package:crm_app/config/config.dart';
import 'package:flutter/material.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  final IconData iconData;
  final Function()? callOnPressed;
  final bool? isDisabled;
  final Widget? child;
  const FloatingActionButtonCustom(
      {super.key,
      required this.callOnPressed,
      required this.iconData,
      this.isDisabled,
      this.child});

  @override
  Widget build(BuildContext context) {
    bool styleDisabled = isDisabled ?? false;
    return SizedBox(
      width: 46 + 9.0 * 2,
      height: 46 + 9.0 * 2,
      child: FloatingActionButton(
        onPressed: isDisabled == true ? null : callOnPressed,
        backgroundColor: styleDisabled
            ? const Color.fromARGB(255, 155, 155, 155)
            : primaryColor,
        shape: const CircleBorder(),
        child: child ??
            Icon(
              iconData,
              size: 32,
              color: Colors.white,
            ),
      ),
    );
  }
}

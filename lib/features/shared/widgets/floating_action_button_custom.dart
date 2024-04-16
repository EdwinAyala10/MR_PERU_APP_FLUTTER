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
      width: 50 + 6.0 * 2,
      height: 50 + 6.0 * 2,
      child: FloatingActionButton(
        onPressed: callOnPressed,
        backgroundColor: styleDisabled
            ? Color.fromARGB(255, 240, 169, 124)
            : const Color.fromARGB(255, 247, 106, 19),
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

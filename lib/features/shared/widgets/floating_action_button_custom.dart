import 'package:flutter/material.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  IconData iconData;
  Function()? callOnPressed;
  FloatingActionButtonCustom({super.key, required this.callOnPressed, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 + 6.0 * 2,
      height: 56 + 6.0 * 2,
      child: FloatingActionButton(
        onPressed: callOnPressed,
        backgroundColor: Color.fromARGB(255, 247, 106, 19),
        shape: const CircleBorder(),
        child: Icon(
          iconData,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
}

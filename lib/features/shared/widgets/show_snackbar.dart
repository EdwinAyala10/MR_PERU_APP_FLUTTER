
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message) {
ScaffoldMessenger.of(context).clearSnackBars();
ScaffoldMessenger.of(context)
  .showSnackBar(SnackBar(content: Text(message)));
}
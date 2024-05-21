import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PlaceholderInput extends StatelessWidget {
  String text;
  PlaceholderInput({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
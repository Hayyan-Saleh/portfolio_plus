import 'package:flutter/material.dart';

class CustomSeperator extends StatelessWidget {
  final double height, width;
  const CustomSeperator({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
            borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

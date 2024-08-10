import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Function onPressed;
  const CustomButton(
      {super.key, required this.onPressed, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(),
      clipBehavior: Clip.antiAlias,
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(
                  color: color ?? Theme.of(context).colorScheme.primary),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(_getWithAlphaColor(context))),
      child: child,
    );
  }

  Color _getWithAlphaColor(BuildContext context) {
    if (color != null) {
      return color!.withAlpha(50);
    } else {
      return Theme.of(context).colorScheme.primary.withAlpha(50);
    }
  }
}

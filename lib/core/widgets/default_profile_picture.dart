import 'package:flutter/material.dart';

class DefaultProfilePicture extends StatelessWidget {
  final double height;
  const DefaultProfilePicture({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 0.10 * height,
      child: Center(
        child: CircleAvatar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          radius: 0.06 * height,
          child: Center(
              child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onBackground,
            size: 0.05 * height,
          )),
        ),
      ),
    );
  }
}

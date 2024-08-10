import 'package:flutter/material.dart';

class CustomAuthButton extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final void Function() onTap;
  const CustomAuthButton(
      {required this.child,
      required this.icon,
      super.key,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primary),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.background,
              ),
              const SizedBox(
                width: 10,
              ),
              child,
            ],
          )),
        ));
  }
}

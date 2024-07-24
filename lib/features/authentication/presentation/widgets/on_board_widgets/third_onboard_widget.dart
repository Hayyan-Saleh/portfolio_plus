import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ThirdOnboardWidget extends StatelessWidget {
  const ThirdOnboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Center(
      child: ListView(children: [
        SizedBox(
          height: 0.02 * height,
        ),
        Text("Portfolio Plus",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 35,
                fontFamily: 'Brilliant',
                color: Theme.of(context).colorScheme.primary)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.03 * height),
          child: Text("Chat !",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
        ),
        SvgPicture.asset(
          'assets/images/svg/onboard_3.svg',
          height: 0.5 * height,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.05 * height),
          child: Text(
              "Speak up and chat with other people who have same interests as you and level up your communications to the next level!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.primary)),
        )
      ]),
    );
  }
}

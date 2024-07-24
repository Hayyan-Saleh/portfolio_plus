import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FirstOnboardWidget extends StatelessWidget {
  const FirstOnboardWidget({super.key});

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
          child: Text("Welcome !",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
        ),
        SvgPicture.asset(
          'assets/images/svg/onboard_1.svg',
          height: 0.5 * height,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.05 * height),
          child: Text(
              "Your only application to create profissional protfolio, publish your projects and connect with others who have similar ideas!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.primary)),
        )
      ]),
    );
  }
}

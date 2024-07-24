import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SecondOnboardWidget extends StatelessWidget {
  const SecondOnboardWidget({super.key});

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
          child: Text("Post !",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
        ),
        SvgPicture.asset(
          'assets/images/svg/onboard_2.svg',
          height: 0.5 * height,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.05 * height),
          child: Text(
              "Make your projects public by posting them and let the world see your creativity to ensure that you are on the right track to follow your dreams!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.primary)),
        )
      ]),
    );
  }
}

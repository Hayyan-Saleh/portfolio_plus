import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';

class EmtpyDataWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  const EmtpyDataWidget(
      {super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    final double height = getHeight(context);
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.all(0.05 * height),
          child: SizedBox(
            height: 0.3 * height,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/svg/empty_data.svg',
              ),
            ),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            subTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

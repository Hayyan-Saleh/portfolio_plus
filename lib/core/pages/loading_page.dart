import 'package:flutter/material.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 0.45 * height,
          ),
          Center(
            child: Text("Portfolio Plus",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Brilliant',
                    color: Theme.of(context).colorScheme.primary)),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.1 * height),
            child:
                LoadingWidget(color: Theme.of(context).colorScheme.secondary),
          )
        ],
      ),
    );
  }
}

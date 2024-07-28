import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  const LoadingWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitWave(
        color: color,
        itemCount: 7,
        type: SpinKitWaveType.center,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

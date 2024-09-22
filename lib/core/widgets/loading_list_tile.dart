import 'package:flutter/material.dart';

class LoadingListTile extends StatelessWidget {
  final double height;
  const LoadingListTile({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 0.15 * height,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    radius: 0.1 * height,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Text(
                          "Lorem ipsum ",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          "Lorem",
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

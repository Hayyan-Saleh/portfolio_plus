import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:extended_image/extended_image.dart';

class ShowImagePage extends StatelessWidget {
  final MessageEntity message;
  const ShowImagePage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(240),
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.black,
                      Colors.black.withAlpha(200),
                      Colors.black,
                    ])),
              ),
            ),
            Center(
              child: ExtendedImage(
                image: CachedNetworkImageProvider(message.content),
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 1.0,
                    maxScale: 3.0,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false,
                    initialAlignment: InitialAlignment.center,
                  );
                },
              ),
            ),
          ],
        ));
  }
}

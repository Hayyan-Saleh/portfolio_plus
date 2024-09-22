import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final bool isRounded;
  final String imageUrl;
  final double height;
  const CustomCachedNetworkImage(
      {super.key,
      required this.isRounded,
      required this.height,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (isRounded) {
      return _buildRoundedCachedImage();
    } else {
      return _buildRegularCachedImage(context);
    }
  }

  Widget _buildRegularCachedImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.primary, width: 0.5),
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary.withAlpha(150),
      ),
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          alignment: Alignment.center,
          fit: BoxFit.cover,
          height: height),
    );
  }

  Widget _buildRoundedCachedImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Center(
          child: CircularProgressIndicator(
              value: downloadProgress.progress,
              backgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.background),
        );
      },
      fit: BoxFit.cover,
      alignment: Alignment.center,
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(
            radius: 0.1 * height,
            backgroundColor:
                Theme.of(context).colorScheme.onPrimary.withAlpha(150),
            foregroundImage: imageProvider);
      },
      errorWidget: (context, url, error) {
        return Center(
          child: Text(
            "Error downloading the image : \n$imageUrl",
            style: TextStyle(
                fontSize: 18, color: Theme.of(context).colorScheme.primary),
          ),
        );
      },
    );
  }
}

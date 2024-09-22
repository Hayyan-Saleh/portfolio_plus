import 'package:flutter/material.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final Function() onPressed;
  const UserListTile({super.key, required this.onPressed, required this.user});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    if (user.accountName != null) {
      return ListTile(
          onTap: () => onPressed(),
          title: Text(
            user.userName!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            user.accountName!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary.withAlpha(175),
                fontWeight: FontWeight.bold),
          ),
          leading: _buildProfilePicture(height));
    } else {
      return const SizedBox();
    }
  }

  Widget _buildProfilePicture(double height) {
    return Stack(
      children: [
        user.profilePictureUrl == null
            ? DefaultProfilePicture(height: 0.55 * height)
            : CircleAvatar(
                radius: 0.055 * height,
                child: CustomCachedNetworkImage(
                    height: 0.33 * height,
                    imageUrl: user.profilePictureUrl!,
                    isRounded: true),
              ),
        Positioned(
          bottom: 7,
          right: 13,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: user.isOffline!
                  ? Colors.grey
                  : Colors.green, // Online status color
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        )
      ],
    );
  }
}

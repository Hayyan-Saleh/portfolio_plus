import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/other_user_page.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    if (user.accountName != null) {
      return ListTile(
          onTap: () => Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: OtherUserPage(
                      user: user,
                    )),
              ),
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

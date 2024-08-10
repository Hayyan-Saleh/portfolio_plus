import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/widgets/custom_button.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/user_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/users_page.dart';

class MainUserPage extends StatelessWidget {
  final UserModel user;
  const MainUserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return ListView(
      children: [
        SizedBox(
          height: 0.2 * height,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 0.05 * width, vertical: 0.04 * height),
            child: _buildBasicUserInfo(context, height),
          ),
        ),
        SizedBox(
          height: 0.1 * height,
          child: _builOtherUserInfoBloc(context, height),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.05 * height),
          child: CustomSeperator(height: 0.004 * height, width: 0.3 * width),
        ),
        SizedBox(
          height: 0.8 * height,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 0.05 * width, vertical: 0.05 * height),
            child: _buildPostsSection(context, height),
          ),
        )
      ],
    );
  }

  Widget _buildPostsSection(BuildContext context, height) {
    return const Center(child: Text("No posts yet"));
  }

  Widget _builOtherUserInfoBloc(context, height) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is LaodedOnlineUserState) {
          return _builOtherUserInfo(context, height, state.user);
        } else if (state is LaodedOfflineUserState) {
          return _builOtherUserInfo(context, height, state.user);
        } else if (state is StoredOnlineUserState) {
          return _builOtherUserInfo(context, height, state.user);
        } else if (state is StoredOfflineUserState) {
          return _builOtherUserInfo(context, height, state.user);
        } else {
          return _builOtherUserInfo(context, height, null);
        }
      },
    );
  }

  Widget _builOtherUserInfo(
      BuildContext context, double height, UserModel? loadedUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowingUserEvent(
                ids: loadedUser != null
                    ? loadedUser.followingIds
                    : user.followingIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const UsersPage()),
            );
          },
          child: SizedBox(
              height: 0.1 * height,
              child: _buildColumn(
                  "Following",
                  loadedUser != null
                      ? loadedUser.followingIds.length.toString()
                      : user.followingIds.length.toString(),
                  context)),
        ),
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowersUserEvent(
                ids: loadedUser != null
                    ? loadedUser.followersIds
                    : user.followersIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const UsersPage()),
            );
          },
          child: SizedBox(
              height: 0.1 * height,
              child: _buildColumn(
                  "Followers",
                  loadedUser != null
                      ? loadedUser.followersIds.length.toString()
                      : user.followersIds.length.toString(),
                  context)),
        ),
        SizedBox(
            height: 0.1 * height,
            child: _buildColumn(
                "Projects",
                loadedUser != null
                    ? loadedUser.userPostsIds.length.toString()
                    : user.userPostsIds.length.toString(),
                context)),
      ],
    );
  }

  Widget _buildBasicUserInfo(BuildContext context, double height) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfilePicture(height),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName ?? "No user name found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  user.accountName ?? "No acccount name found",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: UserInfoPage(
                      user: user,
                    )),
              );
            },
            child: Icon(
              Icons.medical_information_outlined,
              color: Theme.of(context).colorScheme.primary,
            ))
      ],
    );
  }

  Widget _buildProfilePicture(double height) {
    return CircleAvatar(
      radius: 0.05 * height,
      child: Center(
        child: user.profilePictureUrl != null
            ? CustomCachedNetworkImage(
                isRounded: true,
                height: 0.47 * height,
                imageUrl: user.profilePictureUrl!)
            : DefaultProfilePicture(height: 0.8 * height),
      ),
    );
  }

  Widget _buildColumn(
      String firstData, String secondData, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          firstData,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          secondData,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        )
      ],
    );
  }
}

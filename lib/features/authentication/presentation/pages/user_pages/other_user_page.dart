import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_button.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/user_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/users_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_button.dart';

class OtherUserPage extends StatefulWidget {
  final UserModel user;
  const OtherUserPage({super.key, required this.user});

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  UserModel? stateUser;
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
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
          SizedBox(
            height: 0.08 * height,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
                child: _buildFollowBloc()),
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
      ),
    );
  }

  Widget _builOtherUserInfoBloc(BuildContext context, double height) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return _builOtherUserInfo(context, height);
      },
    );
  }

  Widget _buildFollowBloc() {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) async {
        if (state is FollowedUserState) {
          stateUser = state.followedUser;
          BlocProvider.of<UserBloc>(context)
              .add(GetOnlineUserEvent(id: await getId()));
        } else if (state is UnFollowedUserState) {
          stateUser = state.unfollowedUser;
          BlocProvider.of<UserBloc>(context)
              .add(GetOnlineUserEvent(id: await getId()));
        }
      },
      builder: (context, state) {
        if (state is LaodedOnlineUserState) {
          return _buildFollwoingButton(
              context, state.user.followingIds.contains(widget.user.id));
        } else if (state is StoredOnlineUserState) {
          return _buildFollwoingButton(
              context, state.user.followingIds.contains(widget.user.id));
        } else if (state is StoredOfflineUserState) {
          return _buildFollwoingButton(
              context, state.user.followingIds.contains(widget.user.id));
        } else if (state is LoadingFollowingUserState) {
          return CustomAuthButton(
              icon: null,
              onTap: () {},
              child: LoadingWidget(
                  color: Theme.of(context).colorScheme.onPrimary));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildFollwoingButton(BuildContext context, bool isFollowed) {
    return CustomButton(
      onPressed: () async {
        if (isFollowed) {
          BlocProvider.of<UserBloc>(context)
              .add(UnfollowUserEvent(id: widget.user.id));
        } else {
          BlocProvider.of<UserBloc>(context)
              .add(FollowUserEvent(id: widget.user.id));
        }
      },
      child: Text(
          isFollowed
              ? "Unfollow ${widget.user.userName}"
              : "Follow ${widget.user.userName}",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary)),
    );
  }

  Widget _buildPostsSection(BuildContext context, height) {
    return const Center(child: Text("No posts yet"));
  }

  Widget _builOtherUserInfo(BuildContext context, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowingUserEvent(
                ids: stateUser != null
                    ? stateUser!.followingIds
                    : widget.user.followingIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const UsersPage()),
            ).then((value) async {
              context
                  .read<UserBloc>()
                  .add(GetOnlineUserEvent(id: await getId()));
            });
          },
          child: SizedBox(
              height: 0.1 * height,
              child: _buildColumn(
                  "Following",
                  stateUser != null
                      ? stateUser!.followingIds.length.toString()
                      : widget.user.followingIds.length.toString(),
                  context)),
        ),
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowersUserEvent(
                ids: stateUser != null
                    ? stateUser!.followersIds
                    : widget.user.followersIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const UsersPage()),
            ).then((value) async {
              context
                  .read<UserBloc>()
                  .add(GetOnlineUserEvent(id: await getId()));
            });
          },
          child: SizedBox(
            height: 0.1 * height,
            child: _buildColumn(
                "Followers",
                stateUser != null
                    ? stateUser!.followersIds.length.toString()
                    : widget.user.followersIds.length.toString(),
                context),
          ),
        ),
        SizedBox(
            height: 0.1 * height,
            child: _buildColumn(
                "Projects",
                stateUser != null
                    ? stateUser!.userPostsIds.length.toString()
                    : widget.user.userPostsIds.length.toString(),
                context)),
      ],
    );
  }

  Widget _buildBasicUserInfo(BuildContext context, double height) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 0.05 * height,
          child: Center(
            child: _buildProfilePicture(height),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.userName ?? "No user name found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  widget.user.accountName ?? "No acccount name found",
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
                      user: widget.user,
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

  Widget _buildProfilePicture(double height) {
    return Stack(
      children: [
        widget.user.profilePictureUrl != null
            ? CustomCachedNetworkImage(
                isRounded: true,
                height: 0.47 * height,
                imageUrl: widget.user.profilePictureUrl!)
            : DefaultProfilePicture(height: 0.8 * height),
        Positioned(
          bottom: 5,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.user.isOffline!
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/widgets/custom_button.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/user_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/users_page.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_curd_bloc/post_curd_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/pages/add_post_page.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/post_widget.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/widget_size.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainUserPage extends StatefulWidget {
  final UserModel user;
  const MainUserPage({super.key, required this.user});

  @override
  State<MainUserPage> createState() => _MainUserPageState();
}

class _MainUserPageState extends State<MainUserPage> {
  UserModel? _stateUser;
  List<Post>? _userPosts;
  @override
  void initState() {
    BlocProvider.of<UserBloc>(context)
        .add(GetOriginalOnlineUserEvent(id: widget.user.id));
    super.initState();
  }

  void _refreshPage() {
    BlocProvider.of<UserBloc>(context)
        .add(GetOriginalOnlineUserEvent(id: widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: () async {
        _refreshPage();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<PostCurdBloc, PostCurdState>(
            listener: (context, state) {
              if (state is FetchedOriginalPostsCURDState) {
                _userPosts = state.posts;
              } else if (state is DonePostCURDState) {
                _refreshPage();
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is LaodedOriginalOnlineUserState) {
                _stateUser = state.user;
                BlocProvider.of<PostCurdBloc>(context).add(
                    GetOriginalUserPostsCURDEvent(
                        user: _stateUser ?? widget.user));
              } else if (state is LaodedOfflineUserState) {
                _stateUser = state.user;
              } else if (state is StoredOnlineUserState) {
                _stateUser = state.user;
              } else if (state is StoredOfflineUserState) {
                _stateUser = state.user;
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 0.2 * height,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.05 * width,
                      ),
                      child: _buildBasicUserInfo(context, height),
                    ),
                  ),
                  _builOtherUserInfoBloc(context, height),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 0.01 * height,
                        bottom: 0.01 * height,
                        left: 0.2 * width,
                        right: 0.2 * width),
                    child: _buildAddPostBtn(context),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.02 * height),
                    child: CustomSeperator(
                        height: 0.004 * height, width: 0.3 * width),
                  ),
                ],
              ),
              _buildPostsSection(context, height)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsSection(BuildContext context, height) {
    return BlocBuilder<PostCurdBloc, PostCurdState>(
      builder: (context, state) {
        if (state is PostCurdInitial) {
          return const SizedBox();
        } else if (state is LoadingPostCURDState) {
          return _buildUserPosts(true, height);
        } else if (state is FailedPostsCURDState) {
          return Center(
            child: SizedBox(
              height: 0.6 * height,
              child: FailedWidget(
                  title: "Error", subTitle: state.failure.failureMessage),
            ),
          );
        }
        if (_userPosts != null && _userPosts!.isNotEmpty) {
          return _buildUserPosts(false, height);
        }
        return widget.user.userPostsIds.isEmpty
            ? SizedBox(
                height: 0.6 * height,
                child: const EmtpyDataWidget(
                    title: "No Posts Found",
                    subTitle: "Try to create a project and post it here"),
              )
            : const SizedBox();
      },
    );
  }

  Widget _builOtherUserInfoBloc(context, height) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return _builOtherUserInfo(context, height);
      },
    );
  }

  Widget _buildUserPosts(bool isLoading, double height) {
    return Skeletonizer(
        containersColor:
            Theme.of(context).colorScheme.onBackground.withAlpha(150),
        enabled: isLoading,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: isLoading ? 5 : _userPosts!.length,
          itemBuilder: (context, index) => isLoading
              ? LoadingPostWidget(
                  height: 0.5 * height,
                )
              : WidgetSize(
                  child: PostWidget(
                    height: 0.5 * height,
                    isOriginalUserPost: true,
                    originalUser: widget.user,
                    post: _userPosts![index],
                    postUser: widget.user,
                  ),
                  onChange: (size) {
                    setState(() {});
                  },
                ),
          separatorBuilder: (context, index) => Container(
            height: 5,
            color: Theme.of(context).colorScheme.onBackground.withAlpha(50),
          ),
        ));
  }

  Widget _builOtherUserInfo(BuildContext context, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowingUserEvent(
                ids: _stateUser != null
                    ? _stateUser!.followingIds
                    : widget.user.followingIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: UsersPage(originalUser: _stateUser ?? widget.user)),
            );
          },
          child: SizedBox(
              height: 0.1 * height,
              child: _buildColumn(
                  "Following",
                  _stateUser != null
                      ? _stateUser!.followingIds.length.toString()
                      : widget.user.followingIds.length.toString(),
                  context)),
        ),
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowersUserEvent(
                ids: _stateUser != null
                    ? _stateUser!.followersIds
                    : widget.user.followersIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: UsersPage(
                    originalUser: _stateUser ?? widget.user,
                  )),
            );
          },
          child: SizedBox(
              height: 0.1 * height,
              child: _buildColumn(
                  "Followers",
                  _stateUser != null
                      ? _stateUser!.followersIds.length.toString()
                      : widget.user.followersIds.length.toString(),
                  context)),
        ),
        SizedBox(
            height: 0.1 * height,
            child: _buildColumn(
                "Projects",
                _stateUser != null
                    ? _stateUser!.userPostsIds.length.toString()
                    : widget.user.userPostsIds.length.toString(),
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(
                  height: 10,
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

  Widget _buildProfilePicture(double height) {
    return CircleAvatar(
      radius: 0.05 * height,
      child: Center(
        child: widget.user.profilePictureUrl != null
            ? CustomCachedNetworkImage(
                isRounded: true,
                height: 0.47 * height,
                imageUrl: widget.user.profilePictureUrl!)
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

  Widget _buildAddPostBtn(BuildContext context) {
    return CustomButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: AddPostPage(
                  originalUser: widget.user,
                )),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("Add New Project"),
        ));
  }
}

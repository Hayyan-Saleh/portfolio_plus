import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_button.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/user_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/users_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_button.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_curd_bloc/post_curd_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/post_widget.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/widget_size.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class OtherUserPage extends StatefulWidget {
  final UserModel originalUser;
  final UserModel otherUser;

  const OtherUserPage(
      {super.key, required this.originalUser, required this.otherUser});

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  UserModel? _otherUser;
  UserModel? _originalUser;
  List<Post>? _otherUserPosts;

  late final PostCurdBloc _postCurdBloc;
  @override
  void initState() {
    _postCurdBloc = di.sl<PostCurdBloc>();
    _fetchOriginalUser();
    super.initState();
  }

  void _refreshPage() {
    BlocProvider.of<UserBloc>(context)
        .add(GetOriginalOnlineUserEvent(id: widget.originalUser.id));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: buildAppBar(context),
      body: BlocProvider<PostCurdBloc>(
        create: (context) => _postCurdBloc,
        child: MultiBlocListener(
          listeners: [
            BlocListener<PostCurdBloc, PostCurdState>(
              listener: (context, state) {
                if (state is FetchedOtherPostsCURDState) {
                  _otherUserPosts = state.posts;
                } else if (state is DonePostCURDState) {
                  _refreshPage();
                }
              },
            ),
            BlocListener<UserBloc, UserState>(
              listener: (context, state) async {
                if (state is LaodedOriginalOnlineUserState) {
                  _handleOriginalFetchedUser(state.user);
                } else if (state is LaodedOtherOnlineUserState) {
                  _handleOtherFetchedUser(state.user);
                } else if (state is LaodedOfflineUserState) {
                  _handleOriginalFetchedUser(state.user);
                } else if (state is StoredOnlineUserState) {
                  _handleOriginalFetchedUser(state.user);
                } else if (state is StoredOfflineUserState) {
                  _handleOriginalFetchedUser(state.user);
                } else if (state is FollowedUserState) {
                  _originalUser = state.followedUser;
                  BlocProvider.of<UserBloc>(context).add(
                      GetOriginalOnlineUserEvent(id: widget.originalUser.id));
                } else if (state is UnFollowedUserState) {
                  _originalUser = state.unfollowedUser;
                  BlocProvider.of<UserBloc>(context).add(
                      GetOriginalOnlineUserEvent(id: widget.originalUser.id));
                }
              },
            ),
          ],
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshPage();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 0.2 * height,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.05 * width, vertical: 0.04 * height),
                      child: _buildBasicUserInfo(context, height),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _builOtherUserInfoBloc(context, height),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFollowBloc(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.02 * height),
                    child: CustomSeperator(
                        height: 0.004 * height, width: 0.3 * width),
                  ),
                  _buildPostsSection(context, height)
                ],
              ),
            ),
          ),
        ),
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
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is LoadingFollowingUserState) {
          return CustomAuthButton(
              icon: null,
              onTap: () {},
              child: LoadingWidget(
                  color: Theme.of(context).colorScheme.onPrimary));
        }
        if (_originalUser != null) {
          return _buildFollwoingButton(context,
              _originalUser!.followingIds.contains(widget.otherUser.id));
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
              .add(UnfollowUserEvent(id: widget.otherUser.id));
        } else {
          BlocProvider.of<UserBloc>(context)
              .add(FollowUserEvent(id: widget.otherUser.id));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            isFollowed
                ? "Unfollow ${widget.otherUser.userName}"
                : "Follow ${widget.otherUser.userName}",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
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
        } else if (state is FetchedOtherPostsCURDState) {
          if (_otherUserPosts != null && _otherUserPosts!.isNotEmpty) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _otherUserPosts!.length,
              itemBuilder: (context, index) {
                return WidgetSize(
                  child: PostWidget(
                    height: 0.5 * height,
                    isOriginalUserPost: false,
                    originalUser: _originalUser ?? widget.originalUser,
                    post: _otherUserPosts![index],
                    postUser: _otherUser ?? widget.otherUser,
                  ),
                  onChange: (size) {
                    setState(() {});
                  },
                );
              },
              separatorBuilder: (context, index) => Container(
                height: 5,
                color: Theme.of(context).colorScheme.onBackground.withAlpha(50),
              ),
            );
          }
        }
        return widget.otherUser.userPostsIds.isEmpty
            ? SizedBox(
                height: 0.6 * height,
                child: EmtpyDataWidget(
                    title: "No Posts Found",
                    subTitle:
                        "${widget.otherUser.userName} doesn't have projects yet"),
              )
            : const SizedBox();
      },
    );
  }

  Widget _builOtherUserInfo(BuildContext context, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowingUserEvent(
                ids: _otherUser != null
                    ? _otherUser!.followingIds
                    : widget.otherUser.followingIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child:
                      UsersPage(originalUser: _otherUser ?? widget.otherUser)),
            ).then((value) async {
              context
                  .read<UserBloc>()
                  .add(GetOriginalOnlineUserEvent(id: widget.originalUser.id));
            });
          },
          child: SizedBox(
              height: 0.1 * height,
              child: _buildColumn(
                  "Following",
                  _otherUser != null
                      ? _otherUser!.followingIds.length.toString()
                      : widget.otherUser.followingIds.length.toString(),
                  context)),
        ),
        GestureDetector(
          onTap: () {
            BlocProvider.of<UserBloc>(context).add(FetchFollowersUserEvent(
                ids: _otherUser != null
                    ? _otherUser!.followersIds
                    : widget.otherUser.followersIds));
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: UsersPage(
                    originalUser: _otherUser ?? widget.otherUser,
                  )),
            ).then((value) async {
              context
                  .read<UserBloc>()
                  .add(GetOriginalOnlineUserEvent(id: widget.originalUser.id));
            });
          },
          child: SizedBox(
            height: 0.1 * height,
            child: _buildColumn(
                "Followers",
                _otherUser != null
                    ? _otherUser!.followersIds.length.toString()
                    : widget.otherUser.followersIds.length.toString(),
                context),
          ),
        ),
        SizedBox(
            height: 0.1 * height,
            child: _buildColumn(
                "Projects",
                _otherUser != null
                    ? _otherUser!.userPostsIds.length.toString()
                    : widget.otherUser.userPostsIds.length.toString(),
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
                  widget.otherUser.userName ?? "No user name found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  widget.otherUser.accountName ?? "No acccount name found",
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
                      user: widget.otherUser,
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
        widget.otherUser.profilePictureUrl != null
            ? CustomCachedNetworkImage(
                isRounded: true,
                height: 0.47 * height,
                imageUrl: widget.otherUser.profilePictureUrl!)
            : DefaultProfilePicture(height: 0.8 * height),
        Positioned(
          bottom: 5,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.otherUser.isOffline!
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

  Future<void> _fetchOriginalUser() async {
    BlocProvider.of<UserBloc>(context)
        .add(GetOriginalOnlineUserEvent(id: widget.originalUser.id));
  }

  Widget _buildUserPosts(bool isLoading, double height) {
    return Skeletonizer(
        containersColor:
            Theme.of(context).colorScheme.onBackground.withAlpha(150),
        enabled: isLoading,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: isLoading ? 5 : _otherUserPosts!.length,
          itemBuilder: (context, index) => isLoading
              ? LoadingPostWidget(
                  height: 0.5 * height,
                )
              : WidgetSize(
                  child: PostWidget(
                    height: 0.5 * height,
                    isOriginalUserPost: false,
                    originalUser: widget.otherUser,
                    post: _otherUserPosts![index],
                    postUser: widget.otherUser,
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

  _handleOriginalFetchedUser(UserModel user) {
    _originalUser = user;
    BlocProvider.of<UserBloc>(context)
        .add(GetOtherOnlineUserEvent(id: widget.otherUser.id));
  }

  _handleOtherFetchedUser(UserModel user) {
    _otherUser = user;
    _postCurdBloc
        .add(GetOtherUserPostsCURDEvent(user: _otherUser ?? widget.otherUser));
  }
}

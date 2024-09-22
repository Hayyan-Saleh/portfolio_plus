import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_curd_bloc/post_curd_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/post_widget.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/widget_size.dart';
import 'package:portfolio_plus/injection_container.dart' as di;
import 'package:skeletonizer/skeletonizer.dart';

class SavedPostsPage extends StatefulWidget {
  final UserModel originalUser;
  const SavedPostsPage({super.key, required this.originalUser});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  UserModel? _stateUser;
  late final PostCurdBloc _postCurdBloc;
  @override
  void initState() {
    _postCurdBloc = di.sl<PostCurdBloc>();
    super.initState();
  }

  void _refreshPage() {
    BlocProvider.of<UserBloc>(context)
        .add(GetOriginalOnlineUserEvent(id: widget.originalUser.id));
  }

  @override
  Widget build(BuildContext context) {
    final double height = getHeight(context);
    return Scaffold(
      appBar: buildAppBar(context),
      body: BlocProvider(
        create: (context) => _postCurdBloc
          ..add(GetSavedPostsCURDEvent(
              savedPostsIds: widget.originalUser.savedPostsIds)),
        child: MultiBlocListener(
          listeners: [
            BlocListener<UserBloc, UserState>(
              listener: (context, state) {
                if (state is LaodedOriginalOnlineUserState) {
                  _stateUser = state.user;
                  _postCurdBloc.add(GetSavedPostsCURDEvent(
                      savedPostsIds: _stateUser != null
                          ? _stateUser!.savedPostsIds
                          : widget.originalUser.savedPostsIds));
                }
              },
            ),
            BlocListener<PostCurdBloc, PostCurdState>(
              listener: (context, state) {
                if (state is DonePostCURDState) {
                  _refreshPage();
                }
              },
            )
          ],
          child: BlocBuilder<PostCurdBloc, PostCurdState>(
            builder: (context, state) {
              if (state is LoadingPostCURDState) {
                return _buildSavedPosts(true, [], [], height);
              } else if (state is FetchedOtherPostsCURDState) {
                if (state.posts.isEmpty) {
                  return const EmtpyDataWidget(
                      title: "No Saved Posts Found",
                      subTitle:
                          "Try to save some posts in order to see them here");
                }
                return _buildSavedPosts(
                    false, state.posts, state.users, height);
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSavedPosts(
      bool isLoading, List<Post> posts, List<UserModel> users, double height) {
    return Skeletonizer(
        containersColor:
            Theme.of(context).colorScheme.onBackground.withAlpha(150),
        enabled: isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshPage();
          },
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: isLoading ? 5 : posts.length,
            itemBuilder: (context, index) => isLoading
                ? LoadingPostWidget(
                    height: 0.5 * height,
                  )
                : WidgetSize(
                    child: PostWidget(
                        post: posts[index],
                        height: 0.5 * height,
                        postUser: users[index],
                        isOriginalUserPost:
                            widget.originalUser.id == posts[index].userId,
                        originalUser: widget.originalUser),
                    onChange: (size) {
                      setState(() {});
                    },
                  ),
            separatorBuilder: (context, index) => Container(
              height: 5,
              color: Theme.of(context).colorScheme.onBackground.withAlpha(50),
            ),
          ),
        ));
  }
}

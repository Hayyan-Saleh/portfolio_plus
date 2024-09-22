import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/util/globale_variables.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_paging_bloc/posts_paging_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/post_widget.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/widget_size.dart';
import 'package:portfolio_plus/injection_container.dart' as di;
import 'package:skeletonizer/skeletonizer.dart';

class FeedPage extends StatefulWidget {
  final UserModel originalUser;
  const FeedPage({super.key, required this.originalUser});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final List<Post> _posts = [];
  final List<UserModel> _users = [];
  late final PostsPagingBloc _postsPagingBloc;

  bool? _discover = true;
  int fetchCounter = 0;

  void _getPosts() {
    _postsPagingBloc.add(StartPostsPaging(
        originalUser: widget.originalUser, limit: 5, discover: _discover));
  }

  Future<void> _getPostsDelayed() async {
    await Future.delayed(const Duration(seconds: 3));
    _getPosts();
  }

  void _clearData() {
    postsDataCountList.clear();
    _posts.clear();
    _users.clear();
  }

  void _tabListener() {
    _clearData();
    switch (_tabController.index) {
      case 0:
        _discover = true;
        break;
      case 1:
        _discover = false;
        break;
      case 2:
        _discover = null;
        break;
      default:
    }
    _getPosts();
  }

  void _scrollListener() {
    final double maxExtent = _scrollController.position.maxScrollExtent;
    final double currentOffset = _scrollController.offset;
    if (currentOffset > 0.9 * maxExtent) {
      _getPosts();
    }
  }

  @override
  void initState() {
    _postsPagingBloc = di.sl<PostsPagingBloc>();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    _tabController.addListener(_tabListener);
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = getHeight(context);
    final double width = getWidth(context);
    return BlocProvider<PostsPagingBloc>(
      create: (context) => _postsPagingBloc
        ..add(StartPostsPaging(
            originalUser: widget.originalUser, limit: 5, discover: _discover)),
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 0.05 * width, vertical: 0.01 * height),
            child: TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                tabs: [
                  _createTab('Discover'),
                  _createTab('For you'),
                  _createTab('Following'),
                ]),
          ),
          SizedBox(height: 0.8 * height, child: _buildPostsBloc(height)),
        ],
      ),
    );
  }

  Widget _createTab(String text) {
    return Tab(
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildPostsBloc(double height) {
    return BlocConsumer<PostsPagingBloc, PostsPagingState>(
      listener: (context, state) {
        if (state is LoadedPostsPagingState) {
          if (state.posts.isEmpty) {
            if (fetchCounter != 3) {
              _getPostsDelayed();
              fetchCounter++;
            }
          } else {
            _addPosts(state.posts, state.users);
          }
        }
      },
      builder: (context, state) {
        if (_checkForEmptyData()) {
          return const FailedWidget(
              title: "No projects found!",
              subTitle:
                  "Follow some users & create some posts to see posts in this section");
        }
        if (state is PostPagingInitial) {
          return _buildPosts(true, height);
        } else if (state is FailedPostsPagingState) {
          return FailedWidget(
              title: "Error Occured", subTitle: state.failure.failureMessage);
        }
        if (_posts.isEmpty) {
          return _buildPosts(true, height);
        } else {
          return _buildPosts(false, height);
        }
      },
    );
  }

  Widget _buildPosts(bool isLoading, double height) {
    return Skeletonizer(
        containersColor:
            Theme.of(context).colorScheme.onBackground.withAlpha(150),
        enabled: isLoading,
        child: ListView.separated(
          shrinkWrap: true,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: isLoading ? 10 : _posts.length + 1,
          itemBuilder: (context, index) => isLoading
              ? LoadingPostWidget(
                  height: 0.6 * height,
                )
              : index == _posts.length
                  ? Padding(
                      padding: const EdgeInsets.all(15),
                      child: LoadingWidget(
                          color: Theme.of(context).colorScheme.primary),
                    )
                  : WidgetSize(
                      child: PostWidget(
                        height: 0.6 * height,
                        isOriginalUserPost: true,
                        originalUser: widget.originalUser,
                        post: _posts[index],
                        postUser: _users[index],
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

  bool _checkForEmptyData() {
    if (_discover == null && widget.originalUser.followingIds.isEmpty) {
      return true;
    } else if (_discover == false &&
        widget.originalUser.favoritePostTypes.isEmpty) {
      return true;
    }
    return false;
  }

  void _addPosts(List<Post> posts, List<UserModel> users) {
    for (int i = 0; i < posts.length; i++) {
      if (!_posts.contains(posts[i])) {
        _posts.add(posts[i]);
        _users.add(users[i]);
      }
    }
  }
}

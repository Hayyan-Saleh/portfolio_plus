import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_list_tile.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/other_user_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/user_list_tile.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/post_search_bloc/post_search_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/post_widget.dart';
import 'package:portfolio_plus/injection_container.dart' as di;
import 'package:skeletonizer/skeletonizer.dart';

class SearchPage extends StatefulWidget {
  final UserModel originalUser;

  const SearchPage({super.key, required this.originalUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GlobalKey<FormState> searchFormkey = GlobalKey<FormState>();

  final TextEditingController searchTEC = TextEditingController();

  bool _isUserSearchLoading = false;
  bool _isPostSearchLoading = false;

  List<UserModel>? _searchedUsers;
  List<Post>? _searchedPosts;
  List<UserModel>? _searchedPostsUsers;

  late final SearchUsersBloc _searchUsersBloc;
  late final PostSearchBloc _postSearchBloc;
  @override
  void initState() {
    _searchUsersBloc = di.sl<SearchUsersBloc>();
    _postSearchBloc = di.sl<PostSearchBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchUsersBloc>(create: (context) => _searchUsersBloc),
        BlocProvider<PostSearchBloc>(create: (context) => _postSearchBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SearchUsersBloc, SearchUsersState>(
            listener: (context, state) {
              if (state is SearchingUsersState) {
                _isUserSearchLoading = true;
              } else if (state is SearchedUsersState) {
                _isUserSearchLoading = false;
                _searchedUsers = state.users;
              }
            },
          ),
          BlocListener<PostSearchBloc, PostSearchState>(
              listener: (context, state) {
            if (state is SearchingPostsState) {
              _isPostSearchLoading = true;
            } else if (state is SearchedPostsState) {
              _isPostSearchLoading = false;
              _searchedPosts = state.posts;
              _searchedPostsUsers = state.users;
            }
          })
        ],
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 0.03 * height, horizontal: 0.05 * width),
                child: _buildSearchTextField(context)),
            DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 0.05 * width, vertical: 0.01 * height),
                    child: TabBar(
                        indicatorColor: Theme.of(context).colorScheme.secondary,
                        indicator: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(50),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tabs: [
                          Tab(
                            icon: Icon(
                              Icons.person_search_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(
                              "Users",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              Icons.content_paste_search_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(
                              "Posts",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: 0.6 * height,
                    child: TabBarView(children: [
                      _buildUserResultsBloc(height),
                      _buildPostsResultBloc(height)
                    ]),
                  )
                ]))
          ],
        ),
      ),
    );
  }

  Widget _buildUserResultsBloc(double height) {
    return BlocBuilder<SearchUsersBloc, SearchUsersState>(
      builder: (context, state) {
        if (state is SearchUsersInitial) {
          return const SizedBox();
        } else if (state is FailedSearchUsersState) {
          return FailedWidget(
              title: "Error searching for ${searchTEC.text}",
              subTitle: state.message);
        }

        return _buildUserResultWidget(
            _searchedUsers, height, _isUserSearchLoading);
      },
    );
  }

  Widget _buildPostsResultBloc(double height) {
    return BlocBuilder<PostSearchBloc, PostSearchState>(
      builder: (context, state) {
        if (state is PostSearchInitial) {
          return const SizedBox();
        } else if (state is FailedSearchPostsState) {
          return FailedWidget(
              title: "Error searching for ${searchTEC.text}",
              subTitle: state.message);
        }

        return _buildPostsResultWidget(
            _searchedPosts, _searchedPostsUsers, height, _isPostSearchLoading);
      },
    );
  }

  Widget _buildUserResultWidget(
      List<UserModel>? users, double height, bool isLoading) {
    if (!isLoading && users!.isEmpty) {
      return Center(
          child: SizedBox(
              height: 0.8 * height,
              child: const EmtpyDataWidget(
                title: "No users found for this search!",
                subTitle: '',
              )));
    }
    return Skeletonizer(
      enabled: isLoading,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: isLoading ? 10 : users!.length,
        itemBuilder: (context, index) {
          return isLoading
              ? LoadingListTile(height: 0.3 * height)
              : UserListTile(
                  user: users![index],
                  onPressed: () => Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: OtherUserPage(
                          originalUser: widget.originalUser,
                          otherUser: users[index],
                        )),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildPostsResultWidget(List<Post>? posts, List<UserModel>? users,
      double height, bool isLoading) {
    if (!isLoading && posts!.isEmpty) {
      return Center(
          child: SizedBox(
              height: 0.8 * height,
              child: const EmtpyDataWidget(
                title: "No Posts found for this search!",
                subTitle: '',
              )));
    }
    return Skeletonizer(
      enabled: isLoading,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: isLoading ? 10 : posts!.length,
        itemBuilder: (context, index) {
          return isLoading
              ? LoadingPostWidget(height: 0.5 * height)
              : PostWidget(
                  postUser: users![index],
                  post: posts![index],
                  isOriginalUserPost:
                      widget.originalUser.id == posts[index].userId,
                  originalUser: widget.originalUser,
                  height: 0.5 * height,
                );
        },
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context) {
    return Form(
        key: searchFormkey,
        onChanged: () {
          if (searchFormkey.currentState!.validate()) {
            _searchUsersBloc
                .add(GetSearchedUsersEvent(name: searchTEC.text.trim()));
            _postSearchBloc
                .add(GetSearchedPostsEvent(query: searchTEC.text.trim()));
          }
        },
        child: TextFormField(
          controller: searchTEC,
          cursorColor: Theme.of(context).colorScheme.secondary,
          autocorrect: false,
          validator: (val) {
            if (val == null || val == '') {
              return "please enter a user name,account name or project content";
            }
            return null;
          },
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          decoration: InputDecoration(
              errorStyle: const TextStyle(color: Colors.red),
              hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withAlpha(150)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary)),
              hintText: "enter user name or account name",
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary))),
        ));
  }
}

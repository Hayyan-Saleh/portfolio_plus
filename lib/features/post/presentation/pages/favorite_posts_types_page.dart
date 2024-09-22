import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/util/post_type_enum.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/drop_down_button.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_curd_bloc/post_curd_bloc.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class FavoritePostsTypePage extends StatefulWidget {
  final UserModel user;
  const FavoritePostsTypePage({super.key, required this.user});

  @override
  State<FavoritePostsTypePage> createState() => _FavoritePostsTypePageState();
}

class _FavoritePostsTypePageState extends State<FavoritePostsTypePage> {
  String? _selectedFavCategory;
  UserModel? _stateUser;
  late PostCurdBloc _postCurdBloc;
  @override
  void initState() {
    _postCurdBloc = di.sl<PostCurdBloc>();
    super.initState();
  }

  void _refreshUser() {
    BlocProvider.of<UserBloc>(context)
        .add(GetOriginalOnlineUserEvent(id: widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostCurdBloc>(
      create: (context) => _postCurdBloc,
      child: Scaffold(
          appBar: buildAppBar(context),
          body: BlocBuilder<PostCurdBloc, PostCurdState>(
            builder: (context, state) {
              if (state is LoadingPostCURDState) {
                return LoadingWidget(
                    color: Theme.of(context).colorScheme.onBackground);
              } else if (state is DonePostCURDState) {
                _refreshUser();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _refreshUser();
                },
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAddToFavBtn(),
                      BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          if (state is LaodedOriginalOnlineUserState) {
                            _stateUser = state.user;
                          }
                          return _buildFavTypes();
                        },
                      ),
                      const SizedBox(
                        height: 500,
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildFavTypes() {
    final List<String> favTypes =
        _stateUser?.favoritePostTypes ?? widget.user.favoritePostTypes;
    if (favTypes.isEmpty) {
      return const SizedBox(
        height: 500,
        child: EmtpyDataWidget(
            title: "NO Favorite Posts Categories Found!",
            subTitle:
                "Add new favorite categories to see posts based on them!"),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: favTypes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(favTypes[index]),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _postCurdBloc.add(RemovePostCategoryFromFavoritesCURDEvent(
                  postType: favTypes[index], user: widget.user));
            },
          ),
        );
      },
    );
  }

  Widget _buildAddToFavBtn() {
    return Stack(
      children: [
        Container(
          height: 50,
          color:
              Theme.of(context).colorScheme.secondaryContainer.withAlpha(150),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: CustomDropDownButton(
              dropDownTitle: 'Select Project Type',
              onSelect: (selectedList) {
                for (var item in selectedList) {
                  if (item is SelectedListItem) {
                    showSnackBar(context, "${item.name} is selected",
                        const Duration(seconds: 2));
                    _selectedFavCategory = item.name;
                    _postCurdBloc.add(AddPostCategoryToFavoritesCURDEvent(
                        postType: _selectedFavCategory!,
                        user: _stateUser ?? widget.user));
                  }
                }
              },
              buttonTitle: "Add new Favorite Project types",
              dataList: PostType.values
                  .map<String>((element) => element.type)
                  .toList()),
        ),
      ],
    );
  }
}

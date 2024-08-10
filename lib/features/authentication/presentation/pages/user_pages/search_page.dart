import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/user_list_tile.dart';

class SearchPage extends StatelessWidget {
  final GlobalKey<FormState> searchFormkey = GlobalKey<FormState>();
  final TextEditingController searchTextEditingController =
      TextEditingController();
  SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return ListView(
      children: [
        Padding(
            padding: EdgeInsets.symmetric(
                vertical: 0.03 * height, horizontal: 0.05 * width),
            child: _buildSearchTextField(context)),
        BlocBuilder<SearchUsersBloc, SearchUsersState>(
          builder: (context, state) {
            if (state is SearchingUsersState) {
              return Padding(
                padding: EdgeInsets.only(top: 0.27 * height),
                child: LoadingWidget(
                    color: Theme.of(context).colorScheme.onBackground),
              );
            } else if (state is SearchedUsersState) {
              return _buildResultWidget(context, state.users, height);
            } else if (state is FailedSearchUsersState) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildResultWidget(
      BuildContext context, List<UserModel> users, double height) {
    return users.isEmpty
        ? Center(
            child: Padding(
            padding: EdgeInsets.only(top: 0.25 * height),
            child: Text(
              "No users fount",
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          ))
        : SizedBox(
            height: 0.8 * height,
            child: ListView.builder(
              itemCount: users.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.02 * height),
                    child: CustomSeperator(
                        height: 0.005 * height, width: 0.1 * height),
                  );
                }
                return UserListTile(user: users[index - 1]);
              },
            ),
          );
  }

  Widget _buildSearchTextField(BuildContext context) {
    return Form(
        key: searchFormkey,
        onChanged: () {
          if (searchFormkey.currentState!.validate()) {
            BlocProvider.of<SearchUsersBloc>(context).add(GetSearchedUsersEvent(
                name: searchTextEditingController.text.trim()));
          }
        },
        child: TextFormField(
          controller: searchTextEditingController,
          cursorColor: Theme.of(context).colorScheme.secondary,
          autocorrect: false,
          validator: (val) {
            if (val == null || val == '') {
              return "please enter a user name or account name";
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

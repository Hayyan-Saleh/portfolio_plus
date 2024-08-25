import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/other_user_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/user_list_tile.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is LoadingFetchingOnlineUsersEvent) {
            return LoadingWidget(
                color: Theme.of(context).colorScheme.secondary);
          } else if (state is LoadedFollowersUserState) {
            return _buildBody(context, state.users);
          } else if (state is LoadedFollowingUserState) {
            return _buildBody(context, state.users);
          } else if (state is FailedUserState) {
            return FailedWidget(
                title: "Error", subTitle: state.failure.failureMessage);
          }
          return const SizedBox();
        }));
  }

  Widget _buildBody(BuildContext context, List<UserModel> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserListTile(
          user: users[index],
          onPressed: () => Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.bottomToTop,
                child: OtherUserPage(
                  user: users[index],
                )),
          ),
        );
      },
    );
  }
}

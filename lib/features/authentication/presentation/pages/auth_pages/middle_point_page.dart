import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_profile_picture_bloc/user_profile_picture_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/fill_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/home_page.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class MiddlePointPage extends StatefulWidget {
  final UserModel userModel;
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;
  const MiddlePointPage(
      {super.key,
      required this.userModel,
      required this.userBloc,
      required this.authBloc});

  @override
  State<MiddlePointPage> createState() => _MiddlePointPageState();
}

class _MiddlePointPageState extends State<MiddlePointPage> {
  final UserProfilePictureBloc userPorfilePictureBloc =
      di.sl<UserProfilePictureBloc>();
  final UserAccountNameBloc userAccountNameBloc = di.sl<UserAccountNameBloc>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>.value(
      value: widget.userBloc..add(GetOnlineUserEvent(id: widget.userModel.id)),
      child: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is LaodedOnlineUserState) {
            _handleLoadedUser(state.user);
          } else if (state is FailedUserState) {
            if (state.failure.failureMessage == NO_USER_ONLINE_FETCH_ERROR) {
              widget.userBloc.add(StoreOnlineUserEvent(user: widget.userModel));
              _navigateToFillUserInfoPage(user: widget.userModel);
            } else {
              showCustomAboutDialog(context, "Data Fetching Error",
                  state.failure.failureMessage, null, true);
            }
          } else if (state is StoredOnlineUserState) {
            _navigateToFillUserInfoPage(user: state.user);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: buildAppBar(context),
            body: LoadingWidget(color: Theme.of(context).colorScheme.secondary),
          );
        },
      ),
    );
  }

  void _handleLoadedUser(UserModel user) {
    if (user.accountName == '') {
      _navigateToFillUserInfoPage(user: user);
    } else {
      final UserModel authenticatedFetchedUser = createOnlineFetchedUser(
          user: user, authType: widget.userModel.authenticationType);
      widget.userBloc.add(StoreOnlineUserEvent(user: authenticatedFetchedUser));
      widget.userBloc
          .add(StoreOfflineUserEvent(user: authenticatedFetchedUser));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  userAccountNameBloc: di.sl<UserAccountNameBloc>(),
                  userProfilePictureBloc: di.sl<UserProfilePictureBloc>(),
                  searchUsersBloc: di.sl<SearchUsersBloc>(),
                  user: authenticatedFetchedUser,
                  authBloc: widget.authBloc,
                  userBloc: widget.userBloc,
                )),
        (route) => false,
      );
    }
  }

  _navigateToFillUserInfoPage({required user}) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => FillInfoPage(
                userAccountNameBloc: userAccountNameBloc,
                userProfilePictureBloc: userPorfilePictureBloc,
                userModel: createOnlineFetchedUser(
                    user: user, authType: widget.userModel.authenticationType),
                authBloc: widget.authBloc,
                userBloc: widget.userBloc,
              )),
      (route) => false,
    );
  }
}

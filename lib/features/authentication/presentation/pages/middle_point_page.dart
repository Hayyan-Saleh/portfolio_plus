import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_profile_picture_bloc/user_profile_picture_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/fill_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/home_page_test.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class MiddlePointPage extends StatelessWidget {
  final UserModel userModel;
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;
  const MiddlePointPage(
      {super.key,
      required this.userModel,
      required this.userBloc,
      required this.authBloc});

  @override
  Widget build(BuildContext context) {
    final UserProfilePictureBloc userPorfilePictureBloc =
        di.sl<UserProfilePictureBloc>();
    final UserAccountNameBloc userAccountNameBloc =
        di.sl<UserAccountNameBloc>();
    return BlocProvider<UserBloc>.value(
      value: userBloc..add(GetOnlineUserEvent(id: userModel.id)),
      child: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is LaodedOnlineUserState) {
            if (state.user.accountName == '') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => FillInfoPage(
                          userAccountNameBloc: userAccountNameBloc,
                          userProfilePictureBloc: userPorfilePictureBloc,
                          userModel: state.user,
                          authBloc: authBloc,
                          userBloc: userBloc,
                        )),
                (route) => false,
              );
            } else {
              userBloc.add(StoreOfflineUserEvent(
                  user: createOnlineFetchedUser(user: state.user)));
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          authBloc: authBloc,
                          userBloc: userBloc,
                        )),
                (route) => false,
              );
            }
          } else if (state is FailedUserState) {
            if (state.failure.failureMessage == NO_USER_ONLINE_FETCH_ERROR) {
              userBloc.add(StoreOnlineUserEvent(user: userModel));
            } else {
              showCustomAboutDialog(context, "Data Fetching Error",
                  state.failure.failureMessage, null, true);
            }
          } else if (state is StoredOnlineUserState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => FillInfoPage(
                        userAccountNameBloc: userAccountNameBloc,
                        userProfilePictureBloc: userPorfilePictureBloc,
                        userModel: state.user,
                        authBloc: authBloc,
                        userBloc: userBloc,
                      )),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: buildAppBar(context),
            body: const LoadingWidget(),
          );
        },
      ),
    );
  }
}

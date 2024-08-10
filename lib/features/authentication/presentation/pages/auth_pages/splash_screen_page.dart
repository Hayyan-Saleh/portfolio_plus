import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/pages/loading_page.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/middle_point_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/signin_page.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;
  const SplashScreen(
      {super.key, required this.userBloc, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) async {
        await Future.delayed(const Duration(seconds: 1));
        if (state is LaodedOfflineUserState) {
          switch (state.user.authenticationType) {
            case NO_AUTH_TYPE:
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: SigninPage(
                        userBloc: userBloc,
                        authenticationBloc: authBloc,
                      )),
                  (route) => false,
                );
              }
              break;
            case GOOGLE_AUTH_TYPE:
            case EMAIL_PASSWORD_AUTH_TYPE:
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: MiddlePointPage(
                        authBloc: authBloc,
                        userBloc: userBloc,
                        userModel: state.user,
                      )),
                  (route) => false,
                );
              }
              break;
          }
        }
      },
      child: _buildSpalshScreen(context),
    );
  }

  Widget _buildSpalshScreen(BuildContext context) {
    return const LoadingPage();
  }
}

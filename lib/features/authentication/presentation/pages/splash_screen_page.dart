import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/middle_point_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/signin_page.dart';
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
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 0.45 * height,
          ),
          Center(
            child: Text("Portfolio Plus",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Brilliant',
                    color: Theme.of(context).colorScheme.primary)),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.1 * height),
            child:
                LoadingWidget(color: Theme.of(context).colorScheme.secondary),
          )
        ],
      ),
    );
  }
}

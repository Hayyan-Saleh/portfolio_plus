import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/theme/app_themes.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/middle_point_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/on_board_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/signin_page.dart';
import 'package:portfolio_plus/firebase_options.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

void main() async {
  await Hive.initFlutter();
  await di.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = di.sl<UserBloc>();
    return BlocProvider<UserBloc>(
      create: (context) => userBloc..add(GetOfflineUserEvent()),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          Widget widget = const Placeholder();
          bool isDarkTheme = false;
          if (state is FailedUserState) {
            if (state.failure.failureMessage == EMPTY_CACHE_MESSAGE) {
              widget = const OnboardingPage();
            }
          } else if (state is LaodedOfflineUserState) {
            switch (state.user.authenticationType) {
              case NO_AUTH_TYPE:
                widget = SigninPage(
                  userBloc: userBloc,
                  authenticationBloc: di.sl<AuthenticationBloc>(),
                );
              case GOOGLE_AUTH_TYPE:
              case EMAIL_PASSWORD_AUTH_TYPE:
                widget = MiddlePointPage(
                  authBloc: di.sl<AuthenticationBloc>(),
                  userBloc: userBloc,
                  userModel: state.user,
                );
            }
            isDarkTheme = state.user.isDarkMode ?? false;
          }
          return MaterialApp(
            title: "Portfolio Plus",
            debugShowCheckedModeBanner: false,
            theme: isDarkTheme ? darkTheme : lightTheme,
            home: widget,
          );
        },
      ),
    );
  }
}

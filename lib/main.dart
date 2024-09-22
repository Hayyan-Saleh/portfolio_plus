import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/theme/app_themes.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/on_board_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/splash_screen_page.dart';
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
    final AuthenticationBloc authBloc = di.sl<AuthenticationBloc>();
    bool isDarkTheme = false;
    return BlocProvider<UserBloc>(
      create: (context) => userBloc..add(GetOfflineUserEvent()),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          Widget stateWidget = SplashScreen(
            authBloc: authBloc,
            userBloc: userBloc,
          );
          if (state is FailedUserState) {
            if (state.failure.failureMessage == EMPTY_CACHE_MESSAGE) {
              stateWidget = const OnboardingPage();
            }
          } else if (state is LaodedOfflineUserState) {
            isDarkTheme = state.user.isDarkMode ?? false;
          } else if (state is LaodedOriginalOnlineUserState) {
            isDarkTheme = state.user.isDarkMode ?? false;
          } else if (state is StoredOfflineUserState) {
            isDarkTheme = state.user.isDarkMode ?? false;
          } else if (state is StoredOnlineUserState) {
            isDarkTheme = state.user.isDarkMode ?? false;
          }
          return MaterialApp(
            title: "Portfolio Plus",
            debugShowCheckedModeBanner: false,
            theme: isDarkTheme ? darkTheme : lightTheme,
            home: stateWidget,
          );
        },
      ),
    );
  }
}

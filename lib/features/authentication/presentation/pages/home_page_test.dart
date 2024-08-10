import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/signin_page.dart';

class HomePage extends StatefulWidget {
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;
  final UserModel user;
  const HomePage({
    super.key,
    required this.userBloc,
    required this.authBloc,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool signout = false;
  late bool darkMode = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: widget.userBloc),
          BlocProvider.value(value: widget.authBloc),
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  if (state is SignedoutAuthenticationState) {
                    signout = true;
                    widget.userBloc.add(StoreOfflineUserEvent(
                        user: createNoAuthUser(user: state.user)));
                  }
                },
              ),
              BlocListener<UserBloc, UserState>(
                listener: (context, state) {
                  if (state is StoredOfflineUserState && signout) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: SigninPage(
                              authenticationBloc: widget.authBloc,
                              userBloc: widget.userBloc)),
                      (route) => false,
                    );
                  }
                },
              )
            ],
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                Widget stateWidget = const Text("Not working");
                if (state is LoadingUserState) {
                  stateWidget = LoadingWidget(
                    color: Theme.of(context).colorScheme.secondary,
                  );
                } else if (state is StoredOnlineUserState) {
                  darkMode = state.user.isDarkMode ?? darkMode;
                  stateWidget = Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text(
                          "Loaded online user with data : ${state.user.toJson().toString()}"),
                    ),
                  );
                } else if (state is StoredOfflineUserState) {
                  darkMode = state.user.isDarkMode ?? darkMode;
                  stateWidget = Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text(
                          "Loaded offline user with data : ${state.user.toJson().toString()}"),
                    ),
                  );
                }

                return SafeArea(
                  child: Scaffold(
                    appBar: buildAppBar(context),
                    drawer: _buildDrawer(),
                    body: Center(child: stateWidget),
                  ),
                );
              },
            )));
  }

  Widget _buildDrawer() {
    return Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ListView(
          children: [
            const SizedBox(
              height: 50,
            ),
            _buildSignoutButton(context),
            _buildChangeThemeButton(context),
          ],
        ));
  }

  Widget _buildChangeThemeButton(BuildContext context) {
    return SwitchListTile(
        activeColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Dark Mode ",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground),
        ),
        value: darkMode,
        onChanged: (value) {
          setState(() {
            darkMode = value;
            widget.userBloc.add(StoreOfflineUserEvent(
                user: createThemeUser(user: widget.user, isDark: value)));
            widget.userBloc.add(StoreOnlineUserEvent(
                user: createThemeUser(user: widget.user, isDark: value)));
          });
        });
  }

  Widget _buildSignoutButton(BuildContext context) {
    return ListTile(
      title: Text(
        "Sign out",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Icon(
          Icons.logout,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      onTap: () => widget.authBloc.add(SignoutAuthenticationEvent(
          user: createThemeUser(user: widget.user, isDark: darkMode))),
    );
  }
}

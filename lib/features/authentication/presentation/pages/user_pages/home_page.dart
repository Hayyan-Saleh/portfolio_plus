import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/util/globale_variables.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_profile_picture_bloc/user_profile_picture_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/signin_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/change_user_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/main_user_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/search_page.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_boxes_list_bloc/chat_boxes_list_bloc.dart';
import 'package:portfolio_plus/features/chat/presentation/pages/chat_list_page.dart';
import 'package:toastification/toastification.dart';

class HomePage extends StatefulWidget {
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;
  final SearchUsersBloc searchUsersBloc;
  final UserModel user;
  final UserAccountNameBloc userAccountNameBloc;
  final UserProfilePictureBloc userProfilePictureBloc;
  final ChatBoxesListBloc chatBoxesListBloc;
  final int? initialNavbarIndex;
  const HomePage(
      {super.key,
      required this.userBloc,
      required this.userAccountNameBloc,
      required this.userProfilePictureBloc,
      required this.authBloc,
      required this.user,
      required this.searchUsersBloc,
      required this.initialNavbarIndex,
      required this.chatBoxesListBloc});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _signout = false;
  UserModel? userModel;
  late bool _darkMode = false;
  late int _navbarIndex;

  void _changeNavbarIndex(int value) {
    setState(() {
      _navbarIndex = value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //handle bottom navbar initial index
    _navbarIndex = widget.initialNavbarIndex ?? 0;
    //  notification handle
    _handleNotificationMessages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.userBloc.add(StoreOfflineUserEvent(
          user: createClosedAppUser(user: userModel ?? widget.user)));
      widget.userBloc.add(StoreOnlineUserEvent(
          user: createClosedAppUser(user: userModel ?? widget.user)));
    } else if (state == AppLifecycleState.resumed) {
      widget.userBloc.add(StoreOfflineUserEvent(
          user: createOpenedAppUser(user: userModel ?? widget.user)));
      widget.userBloc.add(StoreOnlineUserEvent(
          user: createOpenedAppUser(user: userModel ?? widget.user)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<SearchUsersBloc>.value(value: widget.searchUsersBloc),
          BlocProvider<UserBloc>.value(value: widget.userBloc),
          BlocProvider<AuthenticationBloc>.value(value: widget.authBloc),
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  if (state is SignedoutAuthenticationState) {
                    _signout = true;
                    widget.userBloc.add(StoreOnlineUserEvent(
                        user: createNoAuthUser(user: state.user)));
                    widget.userBloc.add(StoreOfflineUserEvent(
                        user: createNoAuthUser(user: state.user)));
                  }
                },
              ),
              BlocListener<UserBloc, UserState>(
                listener: (context, state) {
                  if (state is StoredOfflineUserState && _signout) {
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
                  _darkMode = state.user.isDarkMode ?? _darkMode;
                  userModel = state.user;
                  stateWidget = Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text(
                          "Stored online user with data : ${state.user.toJson().toString()}"),
                    ),
                  );
                } else if (state is StoredOfflineUserState) {
                  _darkMode = state.user.isDarkMode ?? _darkMode;
                  userModel = state.user;
                  stateWidget = Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text(
                          "Stored offline user with data : ${state.user.toJson().toString()}"),
                    ),
                  );
                } else if (state is LaodedOnlineUserState) {
                  _darkMode = state.user.isDarkMode ?? _darkMode;
                  userModel = state.user;
                  stateWidget = Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text(
                          "Loaded online user with data : ${state.user.toJson().toString()}"),
                    ),
                  );
                } else if (state is LaodedOfflineUserState) {
                  _darkMode = state.user.isDarkMode ?? _darkMode;
                  userModel = state.user;
                  stateWidget = Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text(
                          "Loaded offline user with data : ${state.user.toJson().toString()}"),
                    ),
                  );
                } else if (state is ChangedUserDataState) {
                  _darkMode = state.user.isDarkMode ?? _darkMode;
                  userModel = state.user;
                  stateWidget = Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text(
                          "Changed online user with data : ${state.user.toJson().toString()}"),
                    ),
                  );
                }
                final pages = _getAppPages(stateWidget);
                return SafeArea(
                  child: Scaffold(
                    appBar: buildAppBar(context),
                    drawer: _buildDrawer(),
                    body: pages.elementAt(_navbarIndex),
                    bottomNavigationBar: BottomNavigationBar(
                      currentIndex: _navbarIndex,
                      onTap: (value) => _changeNavbarIndex(value),
                      items: _buildNavbarItems(),
                      elevation: 1,
                      selectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary),
                      unselectedLabelStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(150)),
                      selectedIconTheme: IconThemeData(
                          color: Theme.of(context).colorScheme.primary,
                          size: 30),
                      unselectedIconTheme: IconThemeData(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(150),
                          size: 20),
                    ),
                  ),
                );
              },
            )));
  }

  List<Widget> _getAppPages(Widget stateWidget) {
    return <Widget>[
      _wrapWithLoadUserRefreshIndicator(ListView(
        children: [
          Center(child: stateWidget),
        ],
      )),
      _wrapWithLoadUserRefreshIndicator(SearchPage()),
      _wrapWithLoadUserRefreshIndicator(
          MainUserPage(user: userModel ?? widget.user)),
      ChatListPage(
        originalUser: userModel ?? widget.user,
      )
    ];
  }

  Widget _wrapWithLoadUserRefreshIndicator(Widget page) {
    return RefreshIndicator(
        child: page,
        onRefresh: () async {
          widget.userBloc.add(GetOnlineUserEvent(id: widget.user.id));
        });
  }

  List<BottomNavigationBarItem> _buildNavbarItems() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        backgroundColor:
            Theme.of(context).colorScheme.background.withAlpha(150),
        icon: Icon(
          Icons.home,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        backgroundColor:
            Theme.of(context).colorScheme.background.withAlpha(150),
        icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        backgroundColor:
            Theme.of(context).colorScheme.background.withAlpha(150),
        icon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
        label: 'Profile',
      ),
      BottomNavigationBarItem(
        backgroundColor:
            Theme.of(context).colorScheme.background.withAlpha(150),
        icon: Icon(
          Icons.chat,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: 'Chat',
      ),
    ];
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
            _buildChangeAccountInfoButton(context),
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
        value: _getDarkModeVal(),
        onChanged: (value) {
          setState(() {
            _darkMode = value;
            widget.userBloc.add(StoreOfflineUserEvent(
                user: createThemeUser(
                    user: userModel ?? widget.user, isDark: value)));
            widget.userBloc.add(StoreOnlineUserEvent(
                user: createThemeUser(
                    user: userModel ?? widget.user, isDark: value)));
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
      onTap: () {
        widget.authBloc.add(SignoutAuthenticationEvent(
            user: createThemeUser(user: widget.user, isDark: _darkMode)));
      },
    );
  }

  bool _getDarkModeVal() {
    if (userModel != null) {
      return userModel!.isDarkMode ?? false;
    } else {
      return _darkMode;
    }
  }

  Widget _buildChangeAccountInfoButton(BuildContext context) {
    return ListTile(
        title: Text(
          "Change account info",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Icon(
            Icons.drive_file_rename_outline_outlined,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        onTap: () => Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: ChangeUserInfoPage(
                  userProfilePictureBloc: widget.userProfilePictureBloc,
                  userAccountNameBloc: widget.userAccountNameBloc),
            )));
  }

  Future<void> _firebaseMessagingMessageForegroundHandler(
      BuildContext context, RemoteMessage message) async {
    final String title = message.notification!.title!;
    final String body = message.notification!.body!;
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(title),
      description: Text(body),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      borderRadius: BorderRadius.circular(12),
      progressBarTheme: ProgressIndicatorThemeData(
          linearTrackColor: Theme.of(context).colorScheme.onPrimary,
          color: Theme.of(context).colorScheme.primary.withAlpha(100)),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      callbacks: ToastificationCallbacks(
        onTap: (value) {
          setState(() {
            _navbarIndex = 3;
          });
        },
      ),
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  Future<void> _handleNotificationMessages() async {
    //* Get any messages which caused the application to open from a terminated state.

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.notification!.title!.contains("New Message")) {
        if (jsonDecode(initialMessage.data['otherUserId']) == widget.user.id) {
          setState(() {
            _navbarIndex = 3;
          });
        }
      }
    }

    //* Get any messages which caused the application to open from a background state.

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (message.notification!.title!.contains("New Message")) {
          if (jsonDecode(message.data['otherUserId']) == widget.user.id) {
            setState(() {
              _navbarIndex = 3;
            });
          }
        }
      }
    });

    //* Get any messages which caused the application to open from a foreground state.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (message.notification!.title!.contains("New Message")) {
          if (jsonDecode(message.data['otherUserId']) == widget.user.id &&
              !isOnChatPage) {
            _firebaseMessagingMessageForegroundHandler(context, message);
          }
        }
      }
    });
  }
}

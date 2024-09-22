import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/util/globale_variables.dart';
import 'package:portfolio_plus/core/util/version_validator.dart';
import 'package:portfolio_plus/core/widgets/about_page.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_profile_picture_bloc/user_profile_picture_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/signin_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/change_user_info_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/main_user_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/search_page.dart';
import 'package:portfolio_plus/features/chat/presentation/pages/chat_list_page.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_curd_bloc/post_curd_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/pages/favorite_posts_types_page.dart';
import 'package:portfolio_plus/features/post/presentation/pages/feed_page.dart';
import 'package:portfolio_plus/features/post/presentation/pages/saved_posts_page.dart';
import 'package:portfolio_plus/core/widgets/about_button.dart';
import 'package:toastification/toastification.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class HomePage extends StatefulWidget {
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;
  final UserModel user;
  final UserAccountNameBloc userAccountNameBloc;
  final UserProfilePictureBloc userProfilePictureBloc;
  final int? initialNavbarIndex;

  const HomePage(
      {super.key,
      required this.userBloc,
      required this.authBloc,
      required this.user,
      required this.userAccountNameBloc,
      required this.userProfilePictureBloc,
      this.initialNavbarIndex});

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
    //check for app version
    _checkAppVersion();
    //handle bottom navbar initial index
    _navbarIndex = widget.initialNavbarIndex ?? 0;
    //  notification handle
    _handleNotificationMessages();
    super.initState();
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
          BlocProvider<UserBloc>(create: (context) => widget.userBloc),
          BlocProvider<AuthenticationBloc>(
              create: (context) => widget.authBloc),
          BlocProvider<PostCurdBloc>(
            create: (context) => di.sl<PostCurdBloc>(),
          )
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
                  if (state is StoredOfflineUserState) {
                    if (_signout) {
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
                    _darkMode = state.user.isDarkMode ?? _darkMode;
                    userModel = state.user;
                  } else if (state is StoredOnlineUserState) {
                    _darkMode = state.user.isDarkMode ?? _darkMode;
                    userModel = state.user;
                  } else if (state is LaodedOriginalOnlineUserState) {
                    _darkMode = state.user.isDarkMode ?? _darkMode;
                    userModel = state.user;
                  } else if (state is LaodedOfflineUserState) {
                    _darkMode = state.user.isDarkMode ?? _darkMode;
                    userModel = state.user;
                  } else if (state is ChangedUserDataState) {
                    _darkMode = state.user.isDarkMode ?? _darkMode;
                    userModel = state.user;
                  }
                },
              )
            ],
            child: SafeArea(
              child: Scaffold(
                appBar: buildAppBar(context),
                drawer: _buildDrawer(),
                body: _getAppPages().elementAt(_navbarIndex),
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
                      color: Theme.of(context).colorScheme.primary, size: 30),
                  unselectedIconTheme: IconThemeData(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(150),
                      size: 20),
                ),
              ),
            )));
  }

  List<Widget> _getAppPages() {
    return <Widget>[
      _wrapWithLoadUserRefreshIndicator(FeedPage(
        originalUser: userModel ?? widget.user,
      )),
      _wrapWithLoadUserRefreshIndicator(SearchPage(
        originalUser: userModel ?? widget.user,
      )),
      MainUserPage(user: userModel ?? widget.user),
      ChatListPage(
        originalUser: userModel ?? widget.user,
      )
    ];
  }

  Widget _wrapWithLoadUserRefreshIndicator(Widget page) {
    return RefreshIndicator(
        child: page,
        onRefresh: () async {
          widget.userBloc.add(GetOriginalOnlineUserEvent(id: widget.user.id));
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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(100),
                    Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withAlpha(100),
                    Theme.of(context).colorScheme.background
                  ])),
            ),
            ListView(
              children: [
                const SizedBox(
                  height: 100,
                ),
                _buildSeeSavedPostsButton(),
                _buildChangeThemeButton(),
                _buildChangeFavoriteProjectTypes(),
                _buildChangeAccountInfoButton(),
                _buildSignoutButton(),
                _buildAppLogo(),
              ],
            ),
            Align(
                alignment: Alignment.bottomCenter, child: _buildAnimateButton())
          ],
        ));
  }

  Widget _buildAnimateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20),
      child: AnimatedButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()));
          },
          text: " About "),
    );
  }

  Widget _buildChangeThemeButton() {
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

  Widget _buildSignoutButton() {
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

  Widget _buildChangeFavoriteProjectTypes() {
    return ListTile(
      title: Text(
        "Change favorite project types",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Icon(
          Icons.edit_note_sharp,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: FavoritePostsTypePage(user: userModel ?? widget.user),
                type: PageTransitionType.fade));
      },
    );
  }

  Widget _buildSeeSavedPostsButton() {
    return ListTile(
      title: Text(
        "Saved Projects",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Icon(
          Icons.bookmark,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: SavedPostsPage(originalUser: userModel ?? widget.user),
                type: PageTransitionType.fade));
      },
    );
  }

  Widget _buildAppLogo() {
    return Container(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        children: [
          Text("Portfolio Plus",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'Brilliant',
                  color: Theme.of(context).colorScheme.primary)),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 0.15 * getHeight(context),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              child: Image.asset(
                "assets/icons/app_icon.png",
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _getDarkModeVal() {
    if (userModel != null) {
      return userModel!.isDarkMode ?? false;
    } else {
      return _darkMode;
    }
  }

  Widget _buildChangeAccountInfoButton() {
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
        } else if (message.notification!.title!.contains("New Post")) {
          if (jsonDecode(message.data['otherUserId']) == widget.user.id) {
            _firebaseMessagingMessageForegroundHandler(context, message);
          }
        }
      }
    });
  }

  Future<void> _checkAppVersion() async {
    final int fetchedVersion = await di.sl<VersionValidator>().getVersion();
    if (fetchedVersion != appVersion) {
      await Future.delayed(const Duration(seconds: 3));
      if (context.mounted) {
        showCustomAboutDialog(
            context,
            "Version Error",
            "The current version is: $appVersion doesn't match with the app version: $fetchedVersion \n\n please update the app to the latest version",
            [],
            false);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/signin_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/on_board_widgets/first_onboard_widget.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/on_board_widgets/third_onboard_widget.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/on_board_widgets/second_onboard_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageViewController = PageController();
  int _index = 0;
  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 0.8 * height,
                child: PageView(
                  onPageChanged: (index) {
                    setState(() {
                      _index = index;
                    });
                  },
                  controller: _pageViewController,
                  children: const <Widget>[
                    FirstOnboardWidget(),
                    SecondOnboardWidget(),
                    ThirdOnboardWidget(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.03 * height),
                child: CustomSeperator(
                    height: 0.005 * height, width: 0.09 * height),
              ),
              Container(
                height: 0.05 * height,
                margin: EdgeInsets.symmetric(horizontal: 0.01 * height),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          _pageViewController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear);
                        },
                        child: Text(
                          "Previous",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        )),
                    SmoothPageIndicator(
                      controller: _pageViewController,
                      count: 3,
                    ),
                    TextButton(
                        onPressed: () {
                          if (_index == 2) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: SigninPage(
                                      userBloc: di.sl<UserBloc>(),
                                      authenticationBloc:
                                          di.sl<AuthenticationBloc>())),
                              (route) => false,
                            );
                          }

                          _pageViewController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear);
                        },
                        child: _index == 2
                            ? Text("Done",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary))
                            : Text("Next",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary))),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

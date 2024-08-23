import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/middle_point_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/auth_pages/singup_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_button.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_text_form_field.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

import '../../../../../core/errors/failures.dart';
import '../../../../../core/util/fucntions.dart';

class SigninPage extends StatefulWidget {
  final AuthenticationBloc authenticationBloc;
  final UserBloc userBloc;
  const SigninPage(
      {super.key, required this.authenticationBloc, required this.userBloc});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final passwordResetEmailFormKey = GlobalKey<FormState>();
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final passwordResetEmailTextEditingController = TextEditingController();
  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocProvider<AuthenticationBloc>.value(
        value: widget.authenticationBloc,
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) async {
          if (state is SignedinAuthenticationState) {
            if (state.authType == AuthenticationType.emailPasswordAuth) {
              widget.authenticationBloc
                  .add(SendVerificationEmailAuthenticationEvent());
            } else if (state.authType == AuthenticationType.googleAuth) {
              final String? userFCM = await getUserFCM();
              final bool isNotificationsPermissionGranted =
                  await getNotificationPermission();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => MiddlePointPage(
                            authBloc: widget.authenticationBloc,
                            userBloc: widget.userBloc,
                            userModel: createTemporarUser(
                                isNotificationsPermissionGranted:
                                    isNotificationsPermissionGranted,
                                userFCM: userFCM ?? '',
                                authenticationType:
                                    AuthenticationType.googleAuth,
                                email:
                                    emailTextEditingController.text.trim()))),
                    (route) => false);
              }
            }
          } else if (state is FailedAuthenticationState) {
            if (state.failure is OnlineFailure) {
              showCustomAboutDialog(
                  context,
                  "Online Error",
                  "Please Connect to the internet and try again later",
                  null,
                  true);
            } else if (state.failure.failureMessage ==
                EMAIL_ALREADY_VERIFIED_MESSAGE) {
              final String? userFCM = await getUserFCM();
              final bool isNotificationsPermissionGranted =
                  await getNotificationPermission();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => MiddlePointPage(
                            authBloc: widget.authenticationBloc,
                            userBloc: widget.userBloc,
                            userModel: createTemporarUser(
                                isNotificationsPermissionGranted:
                                    isNotificationsPermissionGranted,
                                userFCM: userFCM ?? "",
                                authenticationType:
                                    AuthenticationType.emailPasswordAuth,
                                email:
                                    emailTextEditingController.text.trim()))),
                    (route) => false);
              }
            } else {
              showCustomAboutDialog(context, "Auth Error !",
                  state.failure.failureMessage, null, true);
            }
          } else if (state is EmailVerificationSentAuthenticationState) {
            _showAboutDialog1(context, emailTextEditingController.text.trim());
          } else if (state is PasswordResetSentAuthenticationState) {
            showSnackBar(context, "Password Reset Email Sent Successfully !",
                const Duration(seconds: 3));
          }
        }, child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            Widget widget = const Placeholder();
            if (state is LoadingAuthenticationState) {
              widget = Center(
                  child: LoadingWidget(
                      color: Theme.of(context).colorScheme.secondary));
            } else {
              widget = _buildBody(height);
            }
            return SafeArea(
              child: Scaffold(
                appBar: buildAppBar(context),
                body: widget,
              ),
            );
          },
        )));
  }

  Widget _buildBody(double height) {
    return ListView(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 0.02 * height),
        child: Text(
          "Sign in",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold),
        ),
      ),
      SvgPicture.asset(
        'assets/images/svg/sign_in.svg',
        height: 0.2 * height,
      ),
      SizedBox(
        height: 0.05 * height,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          "Email : ",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.02 * height),
        child: CustomTextFormField(
            obsecure: false,
            formkey: emailFormKey,
            textEditingController: emailTextEditingController,
            errorMessage: 'please enter your email ',
            hintText: 'Enter your email'),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Text(
          "Password : ",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.02 * height),
        child: CustomTextFormField(
            obsecure: true,
            errorMessage: "Please enter the password",
            hintText: 'Password',
            formkey: passwordFormKey,
            textEditingController: passwordTextEditingController),
      ),
      Padding(
        padding: EdgeInsets.all(0.02 * height),
        child: CustomAuthButton(
            icon: Icons.lock_outlined,
            child: Text('Signin with password',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background)),
            onTap: () {
              if (emailFormKey.currentState!.validate() &&
                  passwordFormKey.currentState!.validate()) {
                widget.authenticationBloc.add(
                    EmailPasswordSigninAuthenticationEvent(
                        email: emailTextEditingController.text.trim(),
                        password: passwordTextEditingController.text.trim()));
              }
            }),
      ),
      Padding(
        padding: EdgeInsets.only(left: 0.02 * height, right: 0.02 * height),
        child: CustomAuthButton(
          icon: Icons.g_mobiledata,
          child: Text('Continue with Google',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.background)),
          onTap: () {
            widget.authenticationBloc.add(GoogleSigninAuthenticationEvent());
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 0.025 * height),
        child: CustomSeperator(height: 0.003 * height, width: 0.1 * height),
      ),
      _buildOtherChoice("Don't have an account ? ", "Sign up", () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SignupPage(
                  authenticationBloc: di.sl<AuthenticationBloc>(),
                )));
      }, 0),
      SizedBox(
        height: 0.015 * height,
      ),
      _buildOtherChoice("Forget password ? ", "Reset Password ", () {
        showCustomAboutDialog(
            context,
            "Password Reset",
            "Please enter your email then go to your email to Reset your password",
            [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextFormField(
                      formkey: passwordResetEmailFormKey,
                      obsecure: false,
                      textEditingController:
                          passwordResetEmailTextEditingController,
                      errorMessage: "please enter your email",
                      hintText: 'enter your email'),
                  SizedBox(
                    height: 0.03 * height,
                  ),
                  CustomAuthButton(
                      icon: null,
                      child: Text(
                        "send password reset email",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.background),
                      ),
                      onTap: () {
                        widget.authenticationBloc.add(
                            SendPasswordResetEmailAuthenticationEvent(
                                email: passwordResetEmailTextEditingController
                                    .text
                                    .trim()));
                        Navigator.of(context).pop();
                      }),
                ],
              )
            ],
            true);
      }, 1),
      SizedBox(
        height: 0.05 * height,
      ),
    ]);
  }

  Widget _buildOtherChoice(
      String firstText, String secondText, Function() onTap, int type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          firstText,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        type == 0
            ? _buildTextButton0(secondText, onTap)
            : _buildTextButton1(secondText, onTap)
      ],
    );
  }

  Widget _buildTextButton0(String secondText, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: "Sign up",
        child: Text(
          secondText,
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextButton1(String secondText, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        secondText,
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAboutDialog1(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            "The email you've just provided isn't verified yet.\nWe sent a verification message to  $email",
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary, fontSize: 16),
          ),
          actions: [
            CustomAuthButton(
              icon: null,
              child: Text('Check Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background)),
              onTap: () {
                // ignore: invalid_use_of_visible_for_testing_member
                widget.authenticationBloc.emit(
                    const SignedinAuthenticationState(
                        authType: AuthenticationType.emailPasswordAuth));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

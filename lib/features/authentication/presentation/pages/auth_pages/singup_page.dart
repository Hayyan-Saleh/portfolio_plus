import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_button.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_text_form_field.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../../core/util/fucntions.dart';

class SignupPage extends StatefulWidget {
  final AuthenticationBloc authenticationBloc;
  const SignupPage({super.key, required this.authenticationBloc});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocProvider<AuthenticationBloc>(
        create: (_) => widget.authenticationBloc,
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) async {
              if (state is SignedupAuthenticationState) {
                BlocProvider.of<AuthenticationBloc>(context)
                    .add(SendVerificationEmailAuthenticationEvent());
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 3),
                    content: Text("Email Verified Successfully !",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.background)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ));
                  Navigator.of(context).pop();
                } else {
                  showCustomAboutDialog(context, "Auth Error !",
                      state.failure.failureMessage, null, true);
                }
              } else if (state is EmailVerificationSentAuthenticationState) {
                showCustomAboutDialog(
                    context,
                    "Email Verification",
                    "The email you've just provided isn't verified yet.\nWe sent a verification message to  ${emailTextEditingController.text.trim()}\n \nAfter verification please login to your account",
                    [
                      CustomAuthButton(
                        icon: Icons.navigate_before,
                        child: Text("Go To Login Page",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.background)),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                    false);
              }
            },
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.background,
                appBar: AppBar(
                  iconTheme: IconThemeData(
                      color: Theme.of(context).colorScheme.primary),
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: Text("Portfolio Plus",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 35,
                          fontFamily: 'Brilliant',
                          color: Theme.of(context).colorScheme.primary)),
                ),
                body: ListView(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.02 * height),
                    child: Hero(
                      tag: "Sign up",
                      child: Text(
                        "Sign up",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold),
                      ),
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
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
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
                  _buildSignupWithPasswordBtn(height)
                ]),
              ),
            )));
  }

  Widget _buildSignupWithPasswordBtn(double height) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        bool isLoading = false;
        if (state is LoadingAuthenticationState) {
          isLoading = true;
        }
        return Padding(
          padding: EdgeInsets.all(0.02 * height),
          child: CustomAuthButton(
              icon: Icons.lock_outlined,
              child: isLoading
                  ? LoadingWidget(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : Text('Sign up with password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background)),
              onTap: () {
                if (emailFormKey.currentState!.validate() &&
                    passwordFormKey.currentState!.validate()) {
                  widget.authenticationBloc.add(
                      EmailPasswordSignupAuthenticationEvent(
                          email: emailTextEditingController.text.trim(),
                          password: passwordTextEditingController.text.trim()));
                }
              }),
        );
      },
    );
  }
}

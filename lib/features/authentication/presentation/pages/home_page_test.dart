import 'package:flutter/material.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';

class HomePage extends StatelessWidget {
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;
  const HomePage({super.key, required this.userBloc, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Test Home Page")),
    );
  }
}

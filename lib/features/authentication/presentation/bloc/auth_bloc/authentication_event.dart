part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class GoogleSigninAuthenticationEvent extends AuthenticationEvent {}

class EmailPasswordSignupAuthenticationEvent extends AuthenticationEvent {
  final String email;
  final String password;

  const EmailPasswordSignupAuthenticationEvent(
      {required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class EmailPasswordSigninAuthenticationEvent extends AuthenticationEvent {
  final String email;
  final String password;

  const EmailPasswordSigninAuthenticationEvent(
      {required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class SendPasswordResetEmailAuthenticationEvent extends AuthenticationEvent {
  final String email;

  const SendPasswordResetEmailAuthenticationEvent({required this.email});
  @override
  List<Object> get props => [email];
}

class SendVerificationEmailAuthenticationEvent extends AuthenticationEvent {}

class SignoutAuthenticationEvent extends AuthenticationEvent {
  final AuthenticationType authType;

  const SignoutAuthenticationEvent({required this.authType});
  @override
  List<Object> get props => [authType];
}

part of 'authentication_bloc.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class SignedoutAuthenticationState extends AuthenticationState {}

class SignedupAuthenticationState extends AuthenticationState {}

class SignedinAuthenticationState extends AuthenticationState {
  final AuthenticationType authType;

  const SignedinAuthenticationState({required this.authType});
  @override
  List<Object> get props => [authType];
}

class EmailNotVerifiedAuthenticationState extends AuthenticationState {}

class EmailVerificationSentAuthenticationState extends AuthenticationState {}

class PasswordResetSentAuthenticationState extends AuthenticationState {}

class LoadingAuthenticationState extends AuthenticationState {}

class FailedAuthenticationState extends AuthenticationState {
  final AppFailure failure;

  const FailedAuthenticationState({required this.failure});
  @override
  List<Object> get props => [failure];
}

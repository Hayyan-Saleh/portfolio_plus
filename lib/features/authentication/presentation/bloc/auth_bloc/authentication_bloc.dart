import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/send_password_reset_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/send_verification_email_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/signin_using_email_password_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/signout_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/signup_using_email_password_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/singin_using_google_use_case.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

typedef AuthCallFunc = Future<Either> Function();

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final SignupUsingEmailPasswordUseCase signupUsingEmailPassword;
  final SendPasswordResetUseCase sendPasswordResetEmail;
  final SendVerificationEmailUseCase sendVerificationEmail;
  final SignoutUseCase signout;
  final SigninUsingEmailPasswordUseCase signinUsingEmailPassword;
  final SigninUsingGoogleUseCase signinUsingGoogle;
  AuthenticationBloc(
      {required this.signupUsingEmailPassword,
      required this.sendPasswordResetEmail,
      required this.sendVerificationEmail,
      required this.signout,
      required this.signinUsingEmailPassword,
      required this.signinUsingGoogle})
      : super(AuthenticationInitial()) {
    on<AuthenticationEvent>((event, emit) async {
      if (event is GoogleSigninAuthenticationEvent) {
        await _mapAuth(
            () => signinUsingGoogle(), emit, AuthenticationType.googleAuth);
      } else if (event is EmailPasswordSigninAuthenticationEvent) {
        await _mapAuth(
            () => signinUsingEmailPassword(event.email, event.password),
            emit,
            AuthenticationType.emailPasswordAuth);
      } else if (event is EmailPasswordSignupAuthenticationEvent) {
        emit(LoadingAuthenticationState());
        final either =
            await signupUsingEmailPassword(event.email, event.password);
        either.fold(
          (failure) {
            emit(FailedAuthenticationState(failure: failure));
          },
          (_) {
            emit(SignedupAuthenticationState());
          },
        );
      } else if (event is SendPasswordResetEmailAuthenticationEvent) {
        emit(LoadingAuthenticationState());
        final either = await sendPasswordResetEmail(event.email);
        either.fold(
          (failure) {
            emit(FailedAuthenticationState(failure: failure));
          },
          (_) {
            emit(PasswordResetSentAuthenticationState());
          },
        );
      } else if (event is SendVerificationEmailAuthenticationEvent) {
        emit(LoadingAuthenticationState());
        final either = await sendVerificationEmail();
        either.fold(
          (failure) {
            emit(FailedAuthenticationState(failure: failure));
          },
          (_) {
            emit(EmailVerificationSentAuthenticationState());
          },
        );
      } else if (event is SignoutAuthenticationEvent) {
        emit(LoadingAuthenticationState());
        final either =
            await signout(_mapAuthType(event.user.authenticationType));
        either.fold(
          (failure) {
            emit(FailedAuthenticationState(failure: failure));
          },
          (_) {
            emit(SignedoutAuthenticationState(user: event.user));
          },
        );
      }
    });
  }
  _mapAuth(AuthCallFunc func, emit, AuthenticationType authType) async {
    emit(LoadingAuthenticationState());
    final either = await func();
    either.fold(
      (failure) {
        emit(FailedAuthenticationState(failure: failure));
      },
      (_) {
        emit(SignedinAuthenticationState(authType: authType));
      },
    );
  }

  AuthenticationType _mapAuthType(String type) {
    AuthenticationType authType = AuthenticationType.noAuth;
    switch (type) {
      case EMAIL_PASSWORD_AUTH_TYPE:
        authType = AuthenticationType.emailPasswordAuth;
        break;
      case GOOGLE_AUTH_TYPE:
        authType = AuthenticationType.googleAuth;
    }
    return authType;
  }
}

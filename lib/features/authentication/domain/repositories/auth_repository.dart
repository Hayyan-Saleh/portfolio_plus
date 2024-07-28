import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';

abstract class AuthRepository extends Equatable {
  Future<Either<AppFailure, Unit>> signinUsingGoogle();
  Future<Either<AppFailure, Unit>> signinUsingEmailPassword(
      String emailAddress, String password);
  Future<Either<AppFailure, Unit>> signupUsingEmailPassword(
      String emailAddress, String password);
  Future<Either<AppFailure, Unit>> sendVerificationEmail();
  Future<Either<AppFailure, Unit>> sendPasswordReset(String email);
  Future<Either<AppFailure, Unit>> signout(
      AuthenticationType authenticationType);
}

import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/network_info/network_info.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';
import 'package:portfolio_plus/features/authentication/data/data_sources/auth_remote_data_source.dart';

import '../../domain/repositories/auth_repository.dart';

typedef AuthFucntion = Future<void> Function();

class AuthRepositoryImp implements AuthRepository {
  final NetworkInfo networkInfo;
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImp(
      {required this.networkInfo, required this.remoteDataSource});
  @override
  Future<Either<AppFailure, Unit>> signupUsingEmailPassword(
      String emailAddress, String password) async {
    return await _auth(() =>
        remoteDataSource.singupUsingEmailPassword(emailAddress, password));
  }

  @override
  Future<Either<AppFailure, Unit>> signinUsingEmailPassword(
      String emailAddress, String password) async {
    return await _auth(() =>
        remoteDataSource.singinUsingEmailPassword(emailAddress, password));
  }

  @override
  Future<Either<AppFailure, Unit>> signinUsingGoogle() async {
    return await _auth(() => remoteDataSource.signinUsingGoogle());
  }

  @override
  Future<Either<AppFailure, Unit>> sendPasswordReset(String email) async {
    return await _auth(() => remoteDataSource.sendPasswordReset(email));
  }

  @override
  Future<Either<AppFailure, Unit>> sendVerificationEmail() async {
    return await _auth(() => remoteDataSource.sendVerificationEmail());
  }

  @override
  Future<Either<AppFailure, Unit>> singout(
      AuthenticationType authenticationType) async {
    throw UnimplementedError();
  }

  Future<Either<AppFailure, Unit>> _auth(AuthFucntion function) async {
    if (await networkInfo.isConnected()) {
      try {
        await function();
      } on AuthExceptiuon catch (exception) {
        return Left(AuthFailure(failureMessage: exception.message));
      }
      return const Right(unit);
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  @override
  List<Object?> get props => [networkInfo, remoteDataSource];

  @override
  bool? get stringify => true;
}

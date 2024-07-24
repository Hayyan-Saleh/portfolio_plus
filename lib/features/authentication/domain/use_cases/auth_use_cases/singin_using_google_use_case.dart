import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/auth_repository.dart';

class SigninUsingGoogleUseCase extends Equatable {
  final AuthRepository authRepository;

  const SigninUsingGoogleUseCase({required this.authRepository});

  Future<Either<AppFailure, Unit>> call() async {
    return await authRepository.signinUsingGoogle();
  }

  @override
  List<Object?> get props => [authRepository];
}

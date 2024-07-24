import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/auth_repository.dart';

class SignupUsingEmailPasswordUseCase extends Equatable {
  final AuthRepository authRepository;

  const SignupUsingEmailPasswordUseCase({required this.authRepository});
  Future<Either<AppFailure, Unit>> call(
      String emailAddress, String password) async {
    return await authRepository.signupUsingEmailPassword(
        emailAddress, password);
  }

  @override
  List<Object?> get props => [authRepository];
}

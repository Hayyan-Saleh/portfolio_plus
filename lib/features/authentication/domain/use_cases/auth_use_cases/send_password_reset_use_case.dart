import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/auth_repository.dart';

class SendPasswordResetUseCase extends Equatable {
  final AuthRepository authRepository;

  const SendPasswordResetUseCase({required this.authRepository});

  Future<Either<AppFailure, Unit>> call(String email) async {
    return await authRepository.sendPasswordReset(email);
  }

  @override
  List<Object?> get props => [authRepository];
}

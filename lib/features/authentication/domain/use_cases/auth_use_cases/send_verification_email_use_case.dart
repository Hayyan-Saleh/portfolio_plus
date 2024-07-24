import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/auth_repository.dart';

class SendVerificationEmailUseCase extends Equatable {
  final AuthRepository authRepository;

  const SendVerificationEmailUseCase({required this.authRepository});

  Future<Either<AppFailure, Unit>> call() async {
    return await authRepository.sendVerificationEmail();
  }

  @override
  List<Object?> get props => [authRepository];
}

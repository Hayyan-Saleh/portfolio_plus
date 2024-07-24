import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/auth_repository.dart';

class SignoutUseCase extends Equatable {
  final AuthRepository authRepository;

  const SignoutUseCase({required this.authRepository});

  Future<Either<AppFailure, Unit>> call(
      AuthenticationType authenticationType) async {
    return await authRepository.singout(authenticationType);
  }

  @override
  List<Object?> get props => [authRepository];
}

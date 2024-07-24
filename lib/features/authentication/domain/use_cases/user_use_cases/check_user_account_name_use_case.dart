import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';

class CheckUserAccountNameUseCase extends Equatable {
  final UserRepository userRepository;

  const CheckUserAccountNameUseCase({required this.userRepository});

  Future<Either<AppFailure, bool>> call(String accountName) async {
    return await userRepository.checkUserAccountName(accountName);
  }

  @override
  List<Object?> get props => [userRepository];
}

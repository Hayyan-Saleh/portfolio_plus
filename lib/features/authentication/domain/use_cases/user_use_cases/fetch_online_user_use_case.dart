import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';

class FetchOnlineUserUseCase extends Equatable {
  final UserRepository userRepository;

  const FetchOnlineUserUseCase({required this.userRepository});

  Future<Either<AppFailure, UserModel>> call(String id) async {
    return await userRepository.fetchOnlineUser(id);
  }

  @override
  List<Object?> get props => [userRepository];
}

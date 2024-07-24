import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';

class StoreOnlineUserUseCase extends Equatable {
  final UserRepository userRepository;

  const StoreOnlineUserUseCase({required this.userRepository});

  Future<Either<AppFailure, UserModel>> call(UserModel user) async {
    return await userRepository.storeOnlineUser(user);
  }

  @override
  List<Object?> get props => [userRepository];
}

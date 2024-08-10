import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';

class GetSearchedUsersUseCase extends Equatable {
  final UserRepository userRepository;

  const GetSearchedUsersUseCase({required this.userRepository});
  Future<Either<AppFailure, List<UserModel>>> call(String name) async {
    return await userRepository.getSearchedUsers(name);
  }

  @override
  List<Object?> get props => [userRepository];
}

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';

class GetUsersByIdsUseCase extends Equatable {
  final UserRepository userRepository;
  const GetUsersByIdsUseCase({required this.userRepository});
  Future<Either<AppFailure, List<UserModel>>> call(List<String> ids) async {
    return await userRepository.getUsersByIds(ids);
  }

  @override
  List<Object> get props => [userRepository];
}

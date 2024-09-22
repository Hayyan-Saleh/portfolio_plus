import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class GetOtherUsersPostsUseCase extends Equatable {
  final PostRepository postRepository;

  const GetOtherUsersPostsUseCase({required this.postRepository});
  Future<Either<AppFailure, List<Post>>> call(
      UserModel originalUser, int limit, bool? discover) async {
    return await postRepository.getOtherUsersPosts(
        originalUser, limit, discover);
  }

  @override
  List<Object?> get props => [postRepository];
}

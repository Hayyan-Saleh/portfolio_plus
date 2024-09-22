import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class GetUserPostsUseCase extends Equatable {
  final PostRepository postRepository;

  const GetUserPostsUseCase({required this.postRepository});
  Future<Either<AppFailure, List<Post>>> call(UserModel user) async {
    return await postRepository.getUserPosts(user);
  }

  @override
  List<Object?> get props => [postRepository];
}

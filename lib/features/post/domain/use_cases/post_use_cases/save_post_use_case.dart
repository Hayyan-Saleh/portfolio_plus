import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class SavePostUseCase extends Equatable {
  final PostRepository postRepository;

  const SavePostUseCase({required this.postRepository});

  Future<Either<AppFailure, Unit>> call(Post post, UserModel user) async {
    return await postRepository.savePost(post, user);
  }

  @override
  List<Object?> get props => [postRepository];
}

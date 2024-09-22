import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class DeletePostUseCase extends Equatable {
  final PostRepository postRepository;

  const DeletePostUseCase({required this.postRepository});
  Future<Either<AppFailure, Unit>> call(Post post) async {
    return await postRepository.deletePost(post);
  }

  @override
  List<Object?> get props => [postRepository];
}

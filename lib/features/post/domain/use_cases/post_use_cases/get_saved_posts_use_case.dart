import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class GetSavedPostsUseCase extends Equatable {
  final PostRepository postRepository;

  const GetSavedPostsUseCase({required this.postRepository});

  Future<Either<AppFailure, List<Post>>> call(
      List<String> savedPostsIds) async {
    return await postRepository.getSavedPosts(savedPostsIds);
  }

  @override
  List<Object?> get props => [postRepository];
}

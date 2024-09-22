import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class GetSearchedPostsUseCase extends Equatable {
  final PostRepository postRepository;

  const GetSearchedPostsUseCase({required this.postRepository});
  Future<Either<AppFailure, List<Post>>> call(String query) async {
    return await postRepository.getSearchedPosts(query);
  }

  @override
  List<Object?> get props => [postRepository];
}

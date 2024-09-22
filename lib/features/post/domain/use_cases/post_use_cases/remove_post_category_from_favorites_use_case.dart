import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class RemovePostCategoryFromFavoritesUseCase extends Equatable {
  final PostRepository postRepository;

  const RemovePostCategoryFromFavoritesUseCase({required this.postRepository});

  Future<Either<AppFailure, Unit>> call(String postType, UserModel user) async {
    return await postRepository.removeFromFavorites(postType, user);
  }

  @override
  List<Object?> get props => [postRepository];
}

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class AddPostCategoryToFavoritesUseCase extends Equatable {
  final PostRepository postRepository;

  const AddPostCategoryToFavoritesUseCase({required this.postRepository});

  Future<Either<AppFailure, Unit>> call(String postType, UserModel user) async {
    return await postRepository.addToFavorites(postType, user);
  }

  @override
  List<Object?> get props => [postRepository];
}

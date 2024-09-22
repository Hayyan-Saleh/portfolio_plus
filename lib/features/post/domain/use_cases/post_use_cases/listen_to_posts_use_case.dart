import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/data/models/post_model.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class ListenToPostsUseCase extends Equatable {
  final PostRepository postRepository;

  const ListenToPostsUseCase({required this.postRepository});
  Future<Either<AppFailure, Unit>> call(StreamController<PostModel> controller,
      UserModel user, bool? discover) async {
    return await postRepository.listenToPosts(controller, user, discover);
  }

  @override
  List<Object?> get props => [postRepository];
}

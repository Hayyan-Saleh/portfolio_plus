import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/repositories/comment_repository.dart';

class ListenToCommentsUseCase extends Equatable {
  final CommentRepository commentRepository;

  const ListenToCommentsUseCase({required this.commentRepository});
  Future<Either<AppFailure, Unit>> call(
      StreamController<Unit> controller, String postId) async {
    return await commentRepository.listenToComments(controller, postId);
  }

  @override
  List<Object?> get props => [commentRepository];
}

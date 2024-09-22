import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/comment_repository.dart';

class RemoveReplyToCommentUseCase extends Equatable {
  final CommentRepository commentRepository;

  const RemoveReplyToCommentUseCase({required this.commentRepository});
  Future<Either<AppFailure, Unit>> call(
      Comment originalComment, Comment replyComment) async {
    return await commentRepository.removeReplyToComment(
        originalComment, replyComment);
  }

  @override
  List<Object?> get props => [commentRepository];
}

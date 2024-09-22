import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/comment_repository.dart';

class AddReplyToCommentUseCase extends Equatable {
  final CommentRepository commentRepository;

  const AddReplyToCommentUseCase({required this.commentRepository});
  Future<Either<AppFailure, Unit>> call(
      Comment originalComment, Comment replyComment) async {
    return await commentRepository.addReplyToComment(
        originalComment, replyComment);
  }

  @override
  List<Object?> get props => [commentRepository];
}

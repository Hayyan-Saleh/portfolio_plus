import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/comment_repository.dart';

class DeleteCommentUseCase extends Equatable {
  final CommentRepository commentRepository;

  const DeleteCommentUseCase({required this.commentRepository});
  Future<Either<AppFailure, Unit>> call(Comment comment) async {
    return await commentRepository.deleteComment(comment);
  }

  @override
  List<Object?> get props => [commentRepository];
}

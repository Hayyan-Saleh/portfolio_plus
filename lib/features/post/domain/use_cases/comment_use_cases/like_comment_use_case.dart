import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/comment_repository.dart';

class LikeCommentUseCase extends Equatable {
  final CommentRepository commentRepository;

  const LikeCommentUseCase({required this.commentRepository});
  Future<Either<AppFailure, Unit>> call(Comment comment, UserModel user) async {
    return await commentRepository.likeComment(comment, user);
  }

  @override
  List<Object?> get props => [commentRepository];
}

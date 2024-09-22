import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/comment_repository.dart';

class GetCommentsUseCase extends Equatable {
  final CommentRepository commentRepository;

  const GetCommentsUseCase({required this.commentRepository});
  Future<Either<AppFailure, List<Comment>>> call(String postId) async {
    return await commentRepository.getComments(postId);
  }

  @override
  List<Object?> get props => [commentRepository];
}

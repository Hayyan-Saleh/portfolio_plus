import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';

abstract class CommentRepository extends Equatable {
  Future<Either<AppFailure, Unit>> addComment(Comment comment);
  Future<Either<AppFailure, Unit>> editComment(Comment comment);
  Future<Either<AppFailure, Unit>> deleteComment(Comment comment);
  Future<Either<AppFailure, Unit>> likeComment(Comment comment, UserModel user);
  Future<Either<AppFailure, Unit>> unlikeComment(
      Comment comment, UserModel user);
  Future<Either<AppFailure, Unit>> addReplyToComment(
      Comment origianlComment, Comment replyComment);
  Future<Either<AppFailure, Unit>> removeReplyToComment(
      Comment origianlComment, Comment replyComment);
  Future<Either<AppFailure, List<Comment>>> getComments(String postId);
  Future<Either<AppFailure, Unit>> listenToComments(
    StreamController<Unit> controller,
    String postId,
  );
}

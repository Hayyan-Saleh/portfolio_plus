import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/network_info/network_info.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/data/repositories/chat_box_repo_impl.dart';
import 'package:portfolio_plus/features/post/data/data_sources/comment_remote_data_source.dart';
import 'package:portfolio_plus/features/post/data/models/comment_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final NetworkInfo networkInfo;
  final CommentRemoteDataSource commentRemoteDataSource;
  const CommentRepositoryImpl(
      {required this.networkInfo, required this.commentRemoteDataSource});
  @override
  Future<Either<AppFailure, Unit>> addComment(Comment comment) async {
    return await _mapCURDInteraction(() =>
        commentRemoteDataSource.addComment(CommentModel.fromEntity(comment)));
  }

  @override
  Future<Either<AppFailure, Unit>> deleteComment(Comment comment) async {
    return await _mapCURDInteraction(() => commentRemoteDataSource
        .deleteComment(CommentModel.fromEntity(comment)));
  }

  @override
  Future<Either<AppFailure, Unit>> editComment(Comment comment) async {
    return await _mapCURDInteraction(() =>
        commentRemoteDataSource.editComment(CommentModel.fromEntity(comment)));
  }

  @override
  Future<Either<AppFailure, Unit>> addReplyToComment(
      Comment origianlComment, Comment replyComment) async {
    return await _mapCURDInteraction(() =>
        commentRemoteDataSource.addReplyToComment(
            CommentModel.fromEntity(origianlComment),
            CommentModel.fromEntity(replyComment)));
  }

  @override
  Future<Either<AppFailure, Unit>> likeComment(
      Comment comment, UserModel user) async {
    return await _mapCURDInteraction(() => commentRemoteDataSource.likeComment(
        CommentModel.fromEntity(comment), user));
  }

  @override
  Future<Either<AppFailure, Unit>> removeReplyToComment(
      Comment origianlComment, Comment replyComment) async {
    return await _mapCURDInteraction(() =>
        commentRemoteDataSource.removeReplyToComment(
            CommentModel.fromEntity(origianlComment),
            CommentModel.fromEntity(replyComment)));
  }

  @override
  Future<Either<AppFailure, Unit>> unlikeComment(
      Comment comment, UserModel user) async {
    return await _mapCURDInteraction(() => commentRemoteDataSource
        .unlikeComment(CommentModel.fromEntity(comment), user));
  }

  @override
  Future<Either<AppFailure, List<Comment>>> getComments(String postId) async {
    if (await networkInfo.isConnected()) {
      try {
        List<Comment> comments =
            await commentRemoteDataSource.getComments(postId);
        return Right(comments);
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> listenToComments(
      StreamController<Unit> controller, String postId) async {
    return _mapCURDInteraction(
        () => commentRemoteDataSource.listenToComments(controller, postId));
  }

  @override
  List<Object?> get props => [networkInfo, commentRemoteDataSource];

  @override
  bool? get stringify => false;

  Future<Either<AppFailure, Unit>> _mapCURDInteraction(CURDFunc func) async {
    if (await networkInfo.isConnected()) {
      try {
        await func();
        return const Right(unit);
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }
}

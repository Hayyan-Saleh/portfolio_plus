import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/add_comment_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/add_reply_to_comment_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/delete_comment_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/edit_comment_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/get_comments_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/like_comment_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/listen_to_comments_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/remove_reply_to_comment_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/comment_use_cases/unlike_comment_use_case.dart';

part 'comment_curd_event.dart';
part 'comment_curd_state.dart';

typedef CommentFunc1 = Future<Either<AppFailure, Unit>> Function();
typedef CommentFunc2 = Future<Either<AppFailure, List<Comment>>> Function();

class CommentCurdBloc extends Bloc<CommentCurdEvent, CommentCurdState> {
  final AddCommentUseCase addComment;
  final DeleteCommentUseCase deleteComment;
  final EditCommentUseCase editComment;
  final AddReplyToCommentUseCase addReplyToComment;
  final RemoveReplyToCommentUseCase removeReplyToComment;
  final LikeCommentUseCase likeComment;
  final UnLikeCommentUseCase unLikeComment;
  final GetCommentsUseCase getComments;
  final FetchOnlineUserUseCase fetchOnlineUser;
  final ListenToCommentsUseCase listenToComments;
  StreamController<Unit> controller = StreamController<Unit>();
  CommentCurdBloc({
    required this.addComment,
    required this.deleteComment,
    required this.editComment,
    required this.addReplyToComment,
    required this.removeReplyToComment,
    required this.likeComment,
    required this.unLikeComment,
    required this.getComments,
    required this.listenToComments,
    required this.fetchOnlineUser,
  }) : super(CommentCurdInitial()) {
    on<CommentCurdEvent>((event, emit) async {
      if (event is AddCommentCURDEvent) {
        await _mapVoidEither(() => addComment(event.comment), emit);
      } else if (event is UpdateCommentCURDEvent) {
        await _mapVoidEither(() => editComment(event.comment), emit);
      } else if (event is DeleteCommentCURDEvent) {
        await _mapVoidEither(() => deleteComment(event.comment), emit);
      } else if (event is LikeCommentCURDEvent) {
        await _mapVoidEither(
            () => likeComment(event.comment, event.user), emit);
      } else if (event is UnLikeCommentCURDEvent) {
        await _mapVoidEither(
            () => unLikeComment(event.comment, event.user), emit);
      } else if (event is AddReplyToCommentCURDEvent) {
        await _mapVoidEither(
            () => addReplyToComment(event.origianlComment, event.replyComment),
            emit);
      } else if (event is RemoveReplyToCommentCURDEvent) {
        await _mapVoidEither(
            () =>
                removeReplyToComment(event.origianlComment, event.replyComment),
            emit);
      } else if (event is GetCommentsCURDEvent) {
        await _mapGetComments(() => getComments(event.postId), emit);
      } else if (event is ListenToCommentsEvent) {
        emit(LoadingCommentCurdState());
        final either = await listenToComments(controller, event.postId);
        either.fold((failure) => emit(FailedCommentState(failure: failure)),
            (comments) {
          controller.stream.listen((Unit unit) {
            add(const ChangeCommentsEvent());
          });
        });
      } else if (event is ChangeCommentsEvent) {
        emit(const ChangedCommentsState());
      }
    });
  }
  Future<void> _mapVoidEither(
      CommentFunc1 func, Emitter<CommentCurdState> emit) async {
    emit(LoadingCommentCurdState());
    final either = await func();
    either.fold((failure) => emit(FailedCommentState(failure: failure)),
        (_) => emit(DoneCommentCurdState()));
  }

  Future<void> _mapGetComments(
    CommentFunc2 func,
    Emitter<CommentCurdState> emit,
  ) async {
    emit(LoadingCommentCurdState());

    final List<Comment> fetchedComments = [];
    final List<UserModel> commentsUsers = [];
    final List<List<UserModel>> commentsReplyUsers = [];

    final either = await func();
    either.fold((failure) => emit(FailedCommentState(failure: failure)),
        (comments) => fetchedComments.addAll(comments));

    for (Comment comment in fetchedComments) {
      List<UserModel> commentReplyUsers = [];
      final either = await fetchOnlineUser(comment.userId);
      either.fold((failure) => emit(FailedCommentState(failure: failure)),
          (user) => commentsUsers.add(user));
      for (Comment replyComment in comment.replyComments) {
        final either = await fetchOnlineUser(replyComment.userId);
        either.fold((failure) => emit(FailedCommentState(failure: failure)),
            (user) => commentReplyUsers.add(user));
      }
      commentsReplyUsers.add(commentReplyUsers);
    }
    emit(LoadedCommentsCurdState(
        comments: fetchedComments,
        commentsUsers: commentsUsers,
        commentsReplyUsers: commentsReplyUsers));
  }
}

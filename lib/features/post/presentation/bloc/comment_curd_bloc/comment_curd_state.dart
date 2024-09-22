part of 'comment_curd_bloc.dart';

sealed class CommentCurdState extends Equatable {
  const CommentCurdState();

  @override
  List<Object> get props => [];
}

final class CommentCurdInitial extends CommentCurdState {}

class LoadingCommentCurdState extends CommentCurdState {}

class DoneCommentCurdState extends CommentCurdState {}

class LoadedCommentsCurdState extends CommentCurdState {
  final List<Comment> comments;
  final List<UserModel> commentsUsers;
  final List<List<UserModel>> commentsReplyUsers;

  const LoadedCommentsCurdState(
      {required this.comments,
      required this.commentsUsers,
      required this.commentsReplyUsers});
  @override
  List<Object> get props => [comments, commentsUsers, commentsReplyUsers];
}

class ChangedCommentsState extends CommentCurdState {
  const ChangedCommentsState();

  @override
  List<Object> get props => [];
}

class FailedCommentState extends CommentCurdState {
  final AppFailure failure;

  const FailedCommentState({required this.failure});
  @override
  List<Object> get props => [failure];
}

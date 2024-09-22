part of 'comment_curd_bloc.dart';

sealed class CommentCurdEvent extends Equatable {
  const CommentCurdEvent();

  @override
  List<Object> get props => [];
}

class AddCommentCURDEvent extends CommentCurdEvent {
  final Comment comment;

  const AddCommentCURDEvent({required this.comment});
  @override
  List<Object> get props => [comment];
}

class UpdateCommentCURDEvent extends CommentCurdEvent {
  final Comment comment;

  const UpdateCommentCURDEvent({required this.comment});
  @override
  List<Object> get props => [comment];
}

class LikeCommentCURDEvent extends CommentCurdEvent {
  final Comment comment;
  final UserModel user;

  const LikeCommentCURDEvent({required this.comment, required this.user});
  @override
  List<Object> get props => [comment, user];
}

class UnLikeCommentCURDEvent extends CommentCurdEvent {
  final Comment comment;
  final UserModel user;

  const UnLikeCommentCURDEvent({required this.comment, required this.user});
  @override
  List<Object> get props => [comment, user];
}

class AddReplyToCommentCURDEvent extends CommentCurdEvent {
  final Comment origianlComment, replyComment;

  const AddReplyToCommentCURDEvent(
      {required this.origianlComment, required this.replyComment});
  @override
  List<Object> get props => [origianlComment, replyComment];
}

class RemoveReplyToCommentCURDEvent extends CommentCurdEvent {
  final Comment origianlComment, replyComment;

  const RemoveReplyToCommentCURDEvent(
      {required this.origianlComment, required this.replyComment});
  @override
  List<Object> get props => [origianlComment, replyComment];
}

class DeleteCommentCURDEvent extends CommentCurdEvent {
  final Comment comment;

  const DeleteCommentCURDEvent({required this.comment});
  @override
  List<Object> get props => [comment];
}

class GetCommentsCURDEvent extends CommentCurdEvent {
  final String postId;

  const GetCommentsCURDEvent({required this.postId});
  @override
  List<Object> get props => [postId];
}

class ListenToCommentsEvent extends CommentCurdEvent {
  final String postId;

  const ListenToCommentsEvent({required this.postId});
  @override
  List<Object> get props => [postId];
}

class ChangeCommentsEvent extends CommentCurdEvent {
  const ChangeCommentsEvent();
  @override
  List<Object> get props => [];
}

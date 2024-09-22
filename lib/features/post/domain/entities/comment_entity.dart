import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String commentId, postId, userId;
  final String content;
  final Timestamp date;
  final bool isEdited;
  final String contentType;
  final List<String> likedUsersIds;
  final List<Comment> replyComments;

  const Comment(
      {required this.commentId,
      required this.postId,
      required this.userId,
      required this.content,
      required this.isEdited,
      required this.date,
      required this.contentType,
      required this.likedUsersIds,
      required this.replyComments});

  @override
  List<Object?> get props => [
        commentId,
        postId,
        userId,
        content,
        date,
        contentType,
        likedUsersIds,
        replyComments,
        isEdited
      ];
}

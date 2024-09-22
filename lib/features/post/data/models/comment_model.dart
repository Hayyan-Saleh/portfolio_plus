import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';

class CommentModel extends Comment {
  const CommentModel({
    required String commentId,
    required String postId,
    required String userId,
    required String content,
    required Timestamp date,
    required String contentType,
    required List<String> likedUsersIds,
    required List<Comment> replyComments,
    required bool isEdited,
  }) : super(
            commentId: commentId,
            postId: postId,
            userId: userId,
            content: content,
            date: date,
            contentType: contentType,
            likedUsersIds: likedUsersIds,
            replyComments: replyComments,
            isEdited: isEdited);

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'],
      postId: json['postId'],
      userId: json['userId'],
      content: json['content'],
      date: json['date'],
      isEdited: json['isEdited'],
      contentType: json['contentType'],
      likedUsersIds: List<String>.from(json['likedUsersIds']),
      replyComments: (json['replyComments'] as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList(),
    );
  }

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
        commentId: comment.commentId,
        postId: comment.postId,
        userId: comment.userId,
        content: comment.content,
        date: comment.date,
        isEdited: comment.isEdited,
        contentType: comment.contentType,
        likedUsersIds: comment.likedUsersIds,
        replyComments: comment.replyComments);
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'content': content,
      'date': date,
      'isEdited': isEdited,
      'contentType': contentType,
      'likedUsersIds': likedUsersIds,
      'replyComments': replyComments
          .map((comment) => (comment as CommentModel).toJson())
          .toList(),
    };
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/data/models/comment_model.dart';

abstract class CommentRemoteDataSource extends Equatable {
  Future<void> addComment(CommentModel comment);
  Future<void> editComment(CommentModel comment);
  Future<void> deleteComment(CommentModel comment);
  Future<void> likeComment(CommentModel comment, UserModel user);
  Future<void> unlikeComment(CommentModel comment, UserModel user);
  Future<void> addReplyToComment(
      CommentModel origianlComment, CommentModel replyComment);
  Future<void> removeReplyToComment(
      CommentModel origianlComment, CommentModel replyComment);
  Future<List<CommentModel>> getComments(String postId);
  Future<void> listenToComments(
    StreamController<Unit> controller,
    String postId,
  );
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  @override
  Future<void> addComment(CommentModel comment) async {
    final DocumentReference commentDocRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.postId)
        .collection('post_comments')
        .doc(comment.commentId);
    await commentDocRef.set(comment.toJson());
  }

  @override
  Future<void> deleteComment(CommentModel comment) async {
    final DocumentReference commentDocRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.postId)
        .collection('post_comments')
        .doc(comment.commentId);
    await commentDocRef.delete();
  }

  @override
  Future<void> editComment(CommentModel comment) async {
    final DocumentReference commentDocRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.postId)
        .collection('post_comments')
        .doc(comment.commentId);
    await commentDocRef.update(comment.toJson());
  }

  @override
  Future<void> likeComment(CommentModel comment, UserModel user) async {
    final DocumentReference commentDocRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.postId)
        .collection('post_comments')
        .doc(comment.commentId);
    await commentDocRef.update({
      'likedUsersIds': FieldValue.arrayUnion([user.id])
    });
  }

  @override
  Future<void> unlikeComment(CommentModel comment, UserModel user) async {
    final DocumentReference commentDocRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.postId)
        .collection('post_comments')
        .doc(comment.commentId);
    await commentDocRef.update({
      'likedUsersIds': FieldValue.arrayRemove([user.id])
    });
  }

  @override
  Future<void> addReplyToComment(
      CommentModel origianlComment, CommentModel replyComment) async {
    final DocumentReference commentDocRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(origianlComment.postId)
        .collection('post_comments')
        .doc(origianlComment.commentId);
    await commentDocRef.update({
      'replyComments': FieldValue.arrayUnion([replyComment.toJson()])
    });
  }

  @override
  Future<void> removeReplyToComment(
      CommentModel origianlComment, CommentModel replyComment) async {
    final DocumentReference commentDocRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(origianlComment.postId)
        .collection('post_comments')
        .doc(origianlComment.commentId);
    await commentDocRef.update({
      'replyComments': FieldValue.arrayRemove([replyComment.toJson()])
    });
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    List<CommentModel> comments = [];
    final QuerySnapshot commentDocs = await FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('post_comments')
        .get();
    for (QueryDocumentSnapshot commentDoc in commentDocs.docs) {
      comments.add(
          CommentModel.fromJson(commentDoc.data() as Map<String, dynamic>));
    }
    comments.sort((firstComment, secondComment) =>
        secondComment.date.compareTo(firstComment.date));
    return comments;
  }

  @override
  Future<void> listenToComments(
      StreamController<Unit> controller, String postId) async {
    final Stream<QuerySnapshot> commentsStream = FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection("post_comments")
        .snapshots();
    commentsStream.listen((QuerySnapshot changedCommentDoc) async {
      if (changedCommentDoc.docChanges.isNotEmpty) {
        controller.add(unit);
      }
    });
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

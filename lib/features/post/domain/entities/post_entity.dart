import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String postId, userId;
  final String postType;
  final Timestamp date;
  final List<String> likedUsersIds;
  final int likesCount;
  final String content;
  final List<String> postPicturesUrls;
  final bool isEdited;

  const Post(
      {required this.postId,
      required this.userId,
      required this.postType,
      required this.date,
      required this.postPicturesUrls,
      required this.likedUsersIds,
      required this.likesCount,
      required this.content,
      required this.isEdited});

  @override
  List<Object?> get props => [
        postId,
        userId,
        postType,
        likedUsersIds,
        date,
        likesCount,
        content,
        postPicturesUrls,
        isEdited
      ];
}

import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';

class PostModel extends Post {
  const PostModel(
      {required super.postId,
      required super.userId,
      required super.postType,
      required super.date,
      required super.postPicturesUrls,
      required super.likedUsersIds,
      required super.content,
      required super.likesCount,
      required super.isEdited});

  factory PostModel.fromJson(Map<String, dynamic> postMap) {
    return PostModel(
        postId: postMap['postId'],
        userId: postMap['userId'],
        postType: postMap['postType'],
        date: postMap['date'],
        postPicturesUrls: List<String>.from(postMap['postPicturesUrls']),
        likedUsersIds: List<String>.from(postMap['likedUsersIds']),
        likesCount: postMap['likesCount'],
        content: postMap['content'],
        isEdited: postMap['isEdited']);
  }
  factory PostModel.fromEntity(Post post) {
    return PostModel(
        postId: post.postId,
        userId: post.userId,
        postType: post.postType,
        date: post.date,
        postPicturesUrls: post.postPicturesUrls,
        likedUsersIds: post.likedUsersIds,
        content: post.content,
        likesCount: post.likesCount,
        isEdited: post.isEdited);
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'postType': postType,
      'date': date,
      'postPicturesUrls': postPicturesUrls,
      'likedUsersIds': likedUsersIds,
      'content': content,
      'isEdited': isEdited,
      'likesCount': likesCount
    };
  }
}

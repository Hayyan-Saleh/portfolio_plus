part of 'post_curd_bloc.dart';

sealed class PostCurdEvent extends Equatable {
  const PostCurdEvent();

  @override
  List<Object> get props => [];
}

class AddPostCURDEvent extends PostCurdEvent {
  final Post post;
  final List<File> pictures;

  const AddPostCURDEvent({required this.post, required this.pictures});
  @override
  List<Object> get props => [post, pictures];
}

class UpdatePostCURDEvent extends PostCurdEvent {
  final Post post;
  final List<File> pictures;

  const UpdatePostCURDEvent({required this.post, required this.pictures});
  @override
  List<Object> get props => [post, pictures];
}

class DeletePostCURDEvent extends PostCurdEvent {
  final Post post;

  const DeletePostCURDEvent({required this.post});
  @override
  List<Object> get props => [post];
}

class SavePostCURDEvent extends PostCurdEvent {
  final Post post;
  final UserModel user;

  const SavePostCURDEvent({required this.post, required this.user});
  @override
  List<Object> get props => [post, user];
}

class UnSavePostCURDEvent extends PostCurdEvent {
  final Post post;
  final UserModel user;

  const UnSavePostCURDEvent({required this.post, required this.user});
  @override
  List<Object> get props => [post, user];
}

class LikePostCURDEvent extends PostCurdEvent {
  final Post post;
  final UserModel user;

  const LikePostCURDEvent({required this.post, required this.user});
  @override
  List<Object> get props => [post, user];
}

class UnLikePostCURDEvent extends PostCurdEvent {
  final Post post;
  final UserModel user;

  const UnLikePostCURDEvent({required this.post, required this.user});
  @override
  List<Object> get props => [post, user];
}

class AddPostCategoryToFavoritesCURDEvent extends PostCurdEvent {
  final String postType;
  final UserModel user;

  const AddPostCategoryToFavoritesCURDEvent(
      {required this.postType, required this.user});
  @override
  List<Object> get props => [postType, user];
}

class RemovePostCategoryFromFavoritesCURDEvent extends PostCurdEvent {
  final String postType;
  final UserModel user;

  const RemovePostCategoryFromFavoritesCURDEvent(
      {required this.postType, required this.user});
  @override
  List<Object> get props => [postType, user];
}

class GetSavedPostsCURDEvent extends PostCurdEvent {
  final List<String> savedPostsIds;

  const GetSavedPostsCURDEvent({required this.savedPostsIds});
  @override
  List<Object> get props => [savedPostsIds];
}

class GetOriginalUserPostsCURDEvent extends PostCurdEvent {
  final UserModel user;

  const GetOriginalUserPostsCURDEvent({required this.user});
  @override
  List<Object> get props => [user];
}

class GetOtherUserPostsCURDEvent extends PostCurdEvent {
  final UserModel user;

  const GetOtherUserPostsCURDEvent({required this.user});
  @override
  List<Object> get props => [user];
}

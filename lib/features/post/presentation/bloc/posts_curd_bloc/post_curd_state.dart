part of 'post_curd_bloc.dart';

sealed class PostCurdState extends Equatable {
  const PostCurdState();

  @override
  List<Object> get props => [];
}

final class PostCurdInitial extends PostCurdState {}

class LoadingPostCURDState extends PostCurdState {}

class DonePostCURDState extends PostCurdState {}

class FetchedOriginalPostsCURDState extends PostCurdState {
  final List<Post> posts;
  final List<UserModel> users;

  const FetchedOriginalPostsCURDState(
      {required this.posts, required this.users});
  @override
  List<Object> get props => [posts, users];
}

class FetchedOtherPostsCURDState extends PostCurdState {
  final List<Post> posts;
  final List<UserModel> users;

  const FetchedOtherPostsCURDState({required this.posts, required this.users});
  @override
  List<Object> get props => [posts, users];
}

class FailedPostsCURDState extends PostCurdState {
  final AppFailure failure;

  const FailedPostsCURDState({required this.failure});
  @override
  List<Object> get props => [failure];
}

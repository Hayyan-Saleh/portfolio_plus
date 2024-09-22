import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/add_post_category_to_favorites_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/add_post_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/delete_post_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/edit_post_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/get_saved_posts_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/get_user_posts_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/like_post_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/remove_post_category_from_favorites_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/save_post_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/unlike_post_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/unsave_post_use_case.dart';

part 'post_curd_event.dart';
part 'post_curd_state.dart';

typedef PostFunc1 = Future<Either<AppFailure, Unit>> Function();
typedef PostFunc2 = Future<Either<AppFailure, List<Post>>> Function();

class PostCurdBloc extends Bloc<PostCurdEvent, PostCurdState> {
  final AddPostUseCase addPost;
  final DeletePostUseCase deletePost;
  final EditPostUseCase editPost;
  final SavePostUseCase savePost;
  final UnSavePostUseCase unSavePost;
  final LikePostUseCase likePost;
  final UnlikePostUseCase unlikePost;
  final AddPostCategoryToFavoritesUseCase addPostCategoryToFavorites;
  final RemovePostCategoryFromFavoritesUseCase removePostCategoryFromFavorites;
  final GetUserPostsUseCase getUserPosts;
  final GetSavedPostsUseCase getSavedPosts;
  final FetchOnlineUserUseCase fetchOnlineUser;
  PostCurdBloc(
      {required this.addPost,
      required this.deletePost,
      required this.editPost,
      required this.getUserPosts,
      required this.getSavedPosts,
      required this.savePost,
      required this.unSavePost,
      required this.likePost,
      required this.unlikePost,
      required this.addPostCategoryToFavorites,
      required this.removePostCategoryFromFavorites,
      required this.fetchOnlineUser})
      : super(PostCurdInitial()) {
    on<PostCurdEvent>((event, emit) async {
      if (event is AddPostCURDEvent) {
        await _mapVoidEither(() => addPost(event.post, event.pictures), emit);
      } else if (event is DeletePostCURDEvent) {
        await _mapVoidEither(() => deletePost(event.post), emit);
      } else if (event is UpdatePostCURDEvent) {
        await _mapVoidEither(() => editPost(event.post, event.pictures), emit);
      } else if (event is SavePostCURDEvent) {
        await _mapVoidEitherWithoutLoading(
            () => savePost(event.post, event.user), emit);
      } else if (event is UnSavePostCURDEvent) {
        await _mapVoidEitherWithoutLoading(
            () => unSavePost(event.post, event.user), emit);
      } else if (event is LikePostCURDEvent) {
        await _mapVoidEitherWithoutLoading(
            () => likePost(event.post, event.user), emit);
      } else if (event is UnLikePostCURDEvent) {
        await _mapVoidEitherWithoutLoading(
            () => unlikePost(event.post, event.user), emit);
      } else if (event is AddPostCategoryToFavoritesCURDEvent) {
        await _mapVoidEither(
            () => addPostCategoryToFavorites(event.postType, event.user), emit);
      } else if (event is RemovePostCategoryFromFavoritesCURDEvent) {
        await _mapVoidEither(
            () => removePostCategoryFromFavorites(event.postType, event.user),
            emit);
      } else if (event is GetOriginalUserPostsCURDEvent) {
        await _mapListEither(() => getUserPosts(event.user), emit, true);
      } else if (event is GetOtherUserPostsCURDEvent) {
        await _mapListEither(() => getUserPosts(event.user), emit, false);
      } else if (event is GetSavedPostsCURDEvent) {
        await _mapListEither(
            () => getSavedPosts(event.savedPostsIds), emit, false);
      }
    });
  }

  Future<void> _mapVoidEitherWithoutLoading(
      PostFunc1 func, Emitter<PostCurdState> emit) async {
    final either = await func();
    either.fold((failure) => emit(FailedPostsCURDState(failure: failure)),
        (_) => emit(DonePostCURDState()));
  }

  Future<void> _mapVoidEither(
      PostFunc1 func, Emitter<PostCurdState> emit) async {
    emit(LoadingPostCURDState());
    final either = await func();
    either.fold((failure) => emit(FailedPostsCURDState(failure: failure)),
        (_) => emit(DonePostCURDState()));
  }

  Future<void> _mapListEither(PostFunc2 func, Emitter<PostCurdState> emit,
      bool isForOriginalUser) async {
    emit(LoadingPostCURDState());
    final either = await func();
    final List<Post> fetchedPosts = [];
    either.fold(
        (failure) => emit(FailedPostsCURDState(failure: failure)),
        (posts) => isForOriginalUser
            ? emit(FetchedOriginalPostsCURDState(posts: posts, users: const []))
            : fetchedPosts.addAll(posts));

    if (!isForOriginalUser) {
      final List<UserModel> fetchedUsers = [];
      for (Post post in fetchedPosts) {
        final either = await fetchOnlineUser(post.userId);
        either.fold((failure) => emit(FailedPostsCURDState(failure: failure)),
            (user) => fetchedUsers.add(user));
      }
      emit(
          FetchedOtherPostsCURDState(posts: fetchedPosts, users: fetchedUsers));
    }
  }
}

import 'dart:async';

import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/network_info/network_info.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/data/data_sources/posts_remote_data_source.dart';
import 'package:portfolio_plus/features/post/data/models/post_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

typedef PostsRepoFunc1 = Future<void> Function();
typedef PostsRepoFunc2 = Future<List<Post>> Function();

class PostsRepositoryImpl implements PostRepository {
  final NetworkInfo networkInfo;
  final PostRemoteDataSource postRemoteDataSource;

  const PostsRepositoryImpl(
      {required this.networkInfo, required this.postRemoteDataSource});
  @override
  Future<Either<AppFailure, Unit>> addPost(
      Post post, List<File> pictures) async {
    return await _mapPostsCURDActions(() =>
        postRemoteDataSource.addPost(PostModel.fromEntity(post), pictures));
  }

  @override
  Future<Either<AppFailure, Unit>> addToFavorites(
      String postType, UserModel user) async {
    return await _mapPostsCURDActions(
        () => postRemoteDataSource.addToFavorites(postType, user));
  }

  @override
  Future<Either<AppFailure, Unit>> deletePost(Post post) async {
    return await _mapPostsCURDActions(
        () => postRemoteDataSource.deletePost(PostModel.fromEntity(post)));
  }

  @override
  Future<Either<AppFailure, Unit>> editPost(
      Post post, List<File> pictures) async {
    return await _mapPostsCURDActions(() =>
        postRemoteDataSource.editPost(PostModel.fromEntity(post), pictures));
  }

  @override
  Future<Either<AppFailure, Unit>> likePost(Post post, UserModel user) async {
    return await _mapPostsCURDActions(
        () => postRemoteDataSource.likePost(PostModel.fromEntity(post), user));
  }

  @override
  Future<Either<AppFailure, Unit>> listenToPosts(
      StreamController<PostModel> controller,
      UserModel user,
      bool? discover) async {
    return await _mapPostsCURDActions(
        () => postRemoteDataSource.listenToPosts(controller, user, discover));
  }

  @override
  Future<Either<AppFailure, Unit>> unSavePost(Post post, UserModel user) async {
    return await _mapPostsCURDActions(() =>
        postRemoteDataSource.unSavePost(PostModel.fromEntity(post), user));
  }

  @override
  Future<Either<AppFailure, Unit>> unlikePost(Post post, UserModel user) async {
    return await _mapPostsCURDActions(() =>
        postRemoteDataSource.unlikePost(PostModel.fromEntity(post), user));
  }

  @override
  Future<Either<AppFailure, Unit>> removeFromFavorites(
      String postType, UserModel user) async {
    return await _mapPostsCURDActions(
        () => postRemoteDataSource.removeToFavorites(postType, user));
  }

  @override
  Future<Either<AppFailure, Unit>> savePost(Post post, UserModel user) async {
    return await _mapPostsCURDActions(
        () => postRemoteDataSource.savePost(PostModel.fromEntity(post), user));
  }

  @override
  Future<Either<AppFailure, List<Post>>> getSearchedPosts(String query) async {
    return await _mapPostsGETActions(
        () => postRemoteDataSource.searchPosts(query));
  }

  @override
  Future<Either<AppFailure, List<Post>>> getOtherUsersPosts(
      UserModel originalUser, int limit, bool? discover) async {
    return await _mapPostsGETActions(() =>
        postRemoteDataSource.getOtherUsersPosts(originalUser, limit, discover));
  }

  @override
  Future<Either<AppFailure, List<Post>>> getSavedPosts(
      List<String> savedPostsIds) async {
    return await _mapPostsGETActions(
        () => postRemoteDataSource.getSavedPost(savedPostsIds));
  }

  @override
  Future<Either<AppFailure, List<Post>>> getUserPosts(UserModel user) async {
    return await _mapPostsGETActions(
        () => postRemoteDataSource.getUserPosts(user));
  }

  @override
  List<Object?> get props => [networkInfo, postRemoteDataSource];

  @override
  bool? get stringify => false;

  Future<Either<AppFailure, Unit>> _mapPostsCURDActions(
      PostsRepoFunc1 func) async {
    if (await networkInfo.isConnected()) {
      try {
        await func();
        return const Right(unit);
      } on OnlineException catch (e) {
        return Left(OnlineFailure(failureMessage: e.message));
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  Future<Either<AppFailure, List<Post>>> _mapPostsGETActions(
      PostsRepoFunc2 func) async {
    if (await networkInfo.isConnected()) {
      try {
        final List<Post> posts = await func();
        return Right(posts);
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }
}

import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/data/models/post_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';

abstract class PostRepository extends Equatable {
  Future<Either<AppFailure, Unit>> addPost(Post post, List<File> pictures);
  Future<Either<AppFailure, Unit>> editPost(Post post, List<File> pictures);
  Future<Either<AppFailure, Unit>> deletePost(Post post);
  Future<Either<AppFailure, Unit>> savePost(Post post, UserModel user);
  Future<Either<AppFailure, Unit>> unSavePost(Post post, UserModel user);
  Future<Either<AppFailure, Unit>> likePost(Post post, UserModel user);
  Future<Either<AppFailure, Unit>> unlikePost(Post post, UserModel user);
  Future<Either<AppFailure, Unit>> addToFavorites(
      String postType, UserModel user);
  Future<Either<AppFailure, Unit>> removeFromFavorites(
      String postType, UserModel user);

  Future<Either<AppFailure, List<Post>>> getSearchedPosts(String query);
  Future<Either<AppFailure, List<Post>>> getSavedPosts(
      List<String> savedPostsIds);
  Future<Either<AppFailure, List<Post>>> getUserPosts(UserModel user);
  Future<Either<AppFailure, List<Post>>> getOtherUsersPosts(
      UserModel originalUser,
      int limit,
      bool? discover); // true = discover false= for you null = following
  Future<Either<AppFailure, Unit>> listenToPosts(
      StreamController<PostModel> controller, UserModel user, bool? discover);
}

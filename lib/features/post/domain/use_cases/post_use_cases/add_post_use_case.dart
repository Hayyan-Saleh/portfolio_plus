import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class AddPostUseCase extends Equatable {
  final PostRepository postRepository;

  const AddPostUseCase({required this.postRepository});
  Future<Either<AppFailure, Unit>> call(Post post, List<File> pictures) async {
    return await postRepository.addPost(post, pictures);
  }

  @override
  List<Object?> get props => [postRepository];
}

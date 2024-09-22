import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/repositories/post_repository.dart';

class EditPostUseCase extends Equatable {
  final PostRepository postRepository;

  const EditPostUseCase({required this.postRepository});
  Future<Either<AppFailure, Unit>> call(Post post, List<File> pictures) async {
    return await postRepository.editPost(post, pictures);
  }

  @override
  List<Object?> get props => [postRepository];
}

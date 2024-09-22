import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/chat/data/models/chat_box_model.dart';
import 'package:portfolio_plus/features/chat/domain/repositories/chat_box_repository.dart';

class ListenToChatBoxUseCase extends Equatable {
  final ChatBoxRepository chatBoxRepository;

  const ListenToChatBoxUseCase({required this.chatBoxRepository});

  Future<Either<AppFailure, Unit>> call(
      String chatBoxId, StreamController<ChatBoxModel> controller) async {
    return await chatBoxRepository.listenToChatBox(chatBoxId, controller);
  }

  @override
  List<Object?> get props => [chatBoxRepository];
}

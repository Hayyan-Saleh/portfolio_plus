import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/data/models/chat_box_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';

abstract class ChatBoxRepository extends Equatable {
  Future<Either<AppFailure, ChatBox>> createChatBox(List<String> usersIds);
  Future<Either<AppFailure, List<ChatBox>>> getChatBoxes(
      List<String> chatBoxesIds);
  Future<Either<AppFailure, Unit>> listenToUser(
      String userId, StreamController<UserModel> controller);
  Future<Either<AppFailure, Unit>> listenToChatBox(
      String chatBoxId, StreamController<ChatBoxModel> controller);
  Future<Either<AppFailure, Unit>> addMessage(UserModel originalUser,
      UserModel otherUser, String chatBoxId, MessageEntity message, File? file);
  Future<Either<AppFailure, Unit>> modifyMessage(
      String chatBoxId, MessageEntity oldMessage, MessageEntity newMessage);
  Future<Either<AppFailure, Unit>> deleteMessage(
      String chatBoxId, MessageEntity message);
}

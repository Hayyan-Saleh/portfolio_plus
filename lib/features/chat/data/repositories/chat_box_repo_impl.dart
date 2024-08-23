import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/network_info/network_info.dart';

import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/data/data_sources/chat_box_remote_data_source.dart';
import 'package:portfolio_plus/features/chat/data/models/chat_box_model.dart';
import 'package:portfolio_plus/features/chat/data/models/message_model.dart';

import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';

import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';

import '../../domain/repositories/chat_box_repository.dart';

typedef CURDFunc = Future<void> Function();
typedef ListenFunc = void Function();

class ChatBoxRepositoryImpl implements ChatBoxRepository {
  final NetworkInfo networkInfo;
  final ChatBoxRemoteDataSource remoteDataSource;

  const ChatBoxRepositoryImpl(
      {required this.networkInfo, required this.remoteDataSource});

  @override
  Future<Either<AppFailure, Unit>> addMessage(UserModel originalUser,
      UserModel otherUser, String chatBoxId, MessageEntity message) async {
    return await _mapCURDInteraction(() => remoteDataSource.addMessage(
        originalUser, otherUser, chatBoxId, _convetToMessageModel(message)));
  }

  @override
  Future<Either<AppFailure, Unit>> deleteMessage(
      String chatBoxId, MessageEntity message) async {
    return await _mapCURDInteraction(() => remoteDataSource.deleteMessage(
        chatBoxId, _convetToMessageModel(message)));
  }

  @override
  Future<Either<AppFailure, Unit>> modifyMessage(String chatBoxId,
      MessageEntity oldMessage, MessageEntity newMessage) async {
    return await _mapCURDInteraction(() => remoteDataSource.modifyMessage(
        chatBoxId,
        _convetToMessageModel(oldMessage),
        _convetToMessageModel(newMessage)));
  }

  @override
  Future<Either<AppFailure, Unit>> listenToChatBox(
      String chatBoxId, StreamController<ChatBoxModel> controller) async {
    return await _mapListenInteraction(
        () => remoteDataSource.listenToChatBox(chatBoxId, controller));
  }

  @override
  Future<Either<AppFailure, Unit>> listenToUser(
      String userId, StreamController<UserModel> controller) async {
    return await _mapListenInteraction(
        () => remoteDataSource.listenToUser(userId, controller));
  }

  @override
  Future<Either<AppFailure, ChatBox>> createChatBox(
      List<String> usersIds) async {
    if (await networkInfo.isConnected()) {
      try {
        return Right(await remoteDataSource.createChatBox(usersIds));
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  @override
  Future<Either<AppFailure, List<ChatBox>>> getChatBoxes(
      List<String> chatBoxesIds) async {
    if (await networkInfo.isConnected()) {
      try {
        return Right(await remoteDataSource.getChatBoxes(chatBoxesIds));
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  @override
  List<Object?> get props => [networkInfo, remoteDataSource];

  @override
  bool? get stringify => false;

  Future<Either<AppFailure, Unit>> _mapListenInteraction(
      ListenFunc func) async {
    if (await networkInfo.isConnected()) {
      try {
        func();
        return const Right(unit);
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  Future<Either<AppFailure, Unit>> _mapCURDInteraction(CURDFunc func) async {
    if (await networkInfo.isConnected()) {
      try {
        await func();
        return const Right(unit);
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  MessageModel _convetToMessageModel(MessageEntity message) {
    return MessageModel(
        senderId: message.senderId,
        date: message.date,
        contentType: message.contentType,
        content: message.content,
        isSeen: message.isSeen,
        isEdited: message.isEdited);
  }
}

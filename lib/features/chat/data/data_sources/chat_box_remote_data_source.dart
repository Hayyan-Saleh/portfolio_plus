import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/data/models/chat_box_model.dart';
import 'package:portfolio_plus/features/chat/data/models/message_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

abstract class ChatBoxRemoteDataSource extends Equatable {
  Future<ChatBoxModel> createChatBox(List<String> usersIds);
  Future<List<ChatBox>> getChatBoxes(List<String> chatBoxesids);
  void listenToUser(String userId, StreamController<UserModel> controller);
  void listenToChatBox(
      String chatBoxId, StreamController<ChatBoxModel> controller);
  Future<void> addMessage(UserModel originalUser, UserModel otherUser,
      String chatBoxId, MessageModel message, File? file);
  Future<void> modifyMessage(
      String chatBoxId, MessageModel oldMessage, MessageModel newMessage);
  Future<void> deleteMessage(String chatBoxId, MessageModel message);
  Future<bool> sendNotification(UserModel originalUser, UserModel otherUser,
      ChatBox chatBox, MessageModel message);
}

class ChatBoxRemoteDataSourceImpl implements ChatBoxRemoteDataSource {
  @override
  Future<ChatBoxModel> createChatBox(List<String> usersIds) async {
    final String chatBoxId = generateUniqueId(usersIds);
    final DocumentReference chatBoxDocRef =
        FirebaseFirestore.instance.collection('chats').doc(chatBoxId);
    await chatBoxDocRef
        .set(_createEmptyChatBoxModel(chatBoxId, usersIds).toJson());
    for (String userId in usersIds) {
      await _addChatBoxIdToUser(userId, chatBoxId);
    }
    return await _getChatBox(chatBoxId);
  }

  @override
  Future<List<ChatBox>> getChatBoxes(List<String> chatBoxesids) async {
    List<ChatBoxModel> chatBoxModels = [];
    for (String chatBoxId in chatBoxesids) {
      chatBoxModels.add(await _getChatBox(chatBoxId));
    }
    chatBoxModels = _sortChatBoxes(chatBoxModels);
    return chatBoxModels;
  }

  @override
  void listenToChatBox(
      String chatBoxId, StreamController<ChatBoxModel> controller) {
    final Stream<DocumentSnapshot> chatBoxSnapshotStream = FirebaseFirestore
        .instance
        .collection('chats')
        .doc(chatBoxId)
        .snapshots();
    chatBoxSnapshotStream.listen((DocumentSnapshot chatBoxDoc) {
      if (chatBoxDoc.exists) {
        controller.add(
            ChatBoxModel.fromJson(chatBoxDoc.data() as Map<String, dynamic>));
      }
    });
  }

  @override
  void listenToUser(String userId, StreamController<UserModel> controller) {
    final Stream<DocumentSnapshot> userSnapshotStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    userSnapshotStream.listen((DocumentSnapshot userDoc) {
      if (userDoc.exists) {
        controller
            .add(UserModel.fromJson(userDoc.data() as Map<String, dynamic>));
      }
    });
  }

  @override
  Future<void> addMessage(UserModel originalUser, UserModel otherUser,
      String chatBoxId, MessageModel message, File? file) async {
    final DocumentReference chatBoxDoc =
        FirebaseFirestore.instance.collection('chats').doc(chatBoxId);
    switch (message.contentType) {
      case IMAGE_CONTENT_TYPE:
        final Reference referenceForStorage = FirebaseStorage.instance
            .ref("users_chat_pictures")
            .child(chatBoxId)
            .child(message.imageName!);
        await referenceForStorage.putFile(file!);
        final String downloadLink = await referenceForStorage.getDownloadURL();
        message = _createImageMessage(message, downloadLink);
        await chatBoxDoc.update({
          'lastMessage': message.toJson(),
          'messages': FieldValue.arrayUnion([message.toJson()])
        });
        break;
      case TEXT_CONTENT_TYPE:
        await chatBoxDoc.update({
          'lastMessage': message.toJson(),
          'messages': FieldValue.arrayUnion([message.toJson()])
        });
        break;
    }

    if (otherUser.isNotificationsPermissionGranted!) {
      final done = await sendNotification(
          originalUser, otherUser, await _getChatBox(chatBoxId), message);
      if (!done) {
        throw OnlineException(message: "Couldn't send Notification");
      }
    }
  }

  @override
  Future<void> deleteMessage(String chatBoxId, MessageModel message) async {
    if (message.contentType == IMAGE_CONTENT_TYPE) {
      final Reference referenceForStorage = FirebaseStorage.instance
          .ref("users_chat_pictures")
          .child(chatBoxId)
          .child(message.imageName!);
      await referenceForStorage.delete();
    }
    final DocumentReference chatBoxDoc =
        FirebaseFirestore.instance.collection('chats').doc(chatBoxId);
    await chatBoxDoc.update({
      'messages': FieldValue.arrayRemove([message.toJson()])
    });
    final DocumentSnapshot chatBoxSnapshot = await chatBoxDoc.get();

    final ChatBoxModel chatBoxModel =
        ChatBoxModel.fromJson(chatBoxSnapshot.data() as Map<String, dynamic>);
    if (chatBoxModel.messages.isEmpty) {
      await chatBoxDoc.update({'lastMessage': null});
    } else {
      final MessageEntity lastMessage = chatBoxModel.lastMessage!;
      if (message == lastMessage) {
        final MessageModel lastChatBoxMessage =
            chatBoxModel.messages.last as MessageModel;
        await chatBoxDoc.update({'lastMessage': lastChatBoxMessage.toJson()});
      }
    }
  }

  @override
  Future<void> modifyMessage(String chatBoxId, MessageModel oldMessage,
      MessageModel newMessage) async {
    final DocumentReference chatBoxDoc =
        FirebaseFirestore.instance.collection('chats').doc(chatBoxId);
    await chatBoxDoc.update({
      'messages': FieldValue.arrayRemove([oldMessage.toJson()])
    });
    await chatBoxDoc.update({
      'messages': FieldValue.arrayUnion([newMessage.toJson()])
    });
    final DocumentSnapshot chatBoxSnapshot = await chatBoxDoc.get();
    final MessageEntity lastMessage =
        ChatBoxModel.fromJson(chatBoxSnapshot.data() as Map<String, dynamic>)
            .lastMessage!; // message is cast down to message model
    if (oldMessage == lastMessage) {
      await chatBoxDoc.update({'lastMessage': newMessage.toJson()});
    }
  }

  @override
  Future<bool> sendNotification(UserModel originalUser, UserModel otherUser,
      ChatBox chatBox, MessageModel message) async {
    final accessToken = await _getAccessToken();
    Map<String, String> headersList = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken"
    };

    Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/portfolio-plus-c2a7a/messages:send');
    Map<String, dynamic> body = {
      "message": {
        "token": otherUser.userFCM,
        "notification": {
          "title": "New Message from ${getFirstName(originalUser.userName!)}",
          "body": message.contentType == IMAGE_CONTENT_TYPE
              ? "Picture"
              : message.content
        },
        "android": {
          "notification": {
            "notification_priority": "PRIORITY_MAX",
            "sound": "default"
          }
        },
        "apns": {
          "payload": {
            "aps": {"content_available": true}
          }
        },
        "data": {
          "type": "message",
          "otherUserId": jsonEncode(otherUser.id),
          "originalUserId": jsonEncode(originalUser.id),
          "chatBoxId": jsonEncode(chatBox.id)
        }
      }
    };
    final req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);
    final res = await req.send();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    } else {
      throw OnlineException(message: res.toString());
    }
  }

  Future<String?> _getAccessToken() async {
    final serviceAccountJson = {}; //TODO: Add your own service credentials

    List<String> scopes = []; //TODO: Add your own scopes

    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      throw OnlineException(message: e.toString());
    }
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;

  ChatBoxModel _createEmptyChatBoxModel(
      String chatBoxId, List<String> usersIds) {
    return ChatBoxModel(
        id: chatBoxId,
        usersIds: usersIds,
        messages: const [],
        lastMessage: null);
  }

  Future<ChatBoxModel> _getChatBox(String id) async {
    final DocumentReference chatBoxDocRef =
        FirebaseFirestore.instance.collection('chats').doc(id);
    final DocumentSnapshot chatBoxSnapShot = await chatBoxDocRef.get();
    return ChatBoxModel.fromJson(
        chatBoxSnapShot.data() as Map<String, dynamic>);
  }

  List<ChatBoxModel> _sortChatBoxes(List<ChatBoxModel> chatBoxModels) {
    chatBoxModels.sort((firstChatBox, secondChatBox) {
      if (firstChatBox.lastMessage != null &&
          secondChatBox.lastMessage != null) {
        return secondChatBox.lastMessage!.date
            .compareTo(firstChatBox.lastMessage!.date);
      } else if (firstChatBox.lastMessage == null &&
          secondChatBox.lastMessage == null) {
        return 0;
      } else if (firstChatBox.lastMessage == null) {
        return 1;
      } else {
        return -1;
      }
    });
    return chatBoxModels;
  }

  Future<void> _addChatBoxIdToUser(String userId, String chatId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'chatIds': FieldValue.arrayUnion([chatId])
    });
  }

  MessageModel _createImageMessage(
      MessageModel messageModel, String downloadLink) {
    return MessageModel(
        senderId: messageModel.senderId,
        imageName: messageModel.imageName,
        date: messageModel.date,
        contentType: messageModel.contentType,
        content: downloadLink,
        isSeen: messageModel.isSeen,
        isEdited: messageModel.isEdited);
  }
}

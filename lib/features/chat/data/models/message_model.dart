import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel(
      {required super.senderId,
      required super.date,
      required super.contentType,
      required super.content,
      required super.isSeen,
      required super.isEdited,
      required super.imageName});
  factory MessageModel.fromJson(Map<String, dynamic> messageMap) {
    return MessageModel(
        senderId: messageMap['senderId'],
        imageName: messageMap['imageName'],
        date: messageMap['date'],
        contentType: messageMap['contentType'],
        content: messageMap['content'],
        isSeen: messageMap['isSeen'],
        isEdited: messageMap['isEdited']);
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'imageName': imageName,
      'date': date,
      'contentType': contentType,
      'content': content,
      'isSeen': isSeen,
      'isEdited': isEdited
    };
  }
}

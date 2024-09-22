import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String senderId;
  final String? imageName;
  final String contentType;
  final String content;
  final bool isSeen;
  final bool isEdited;
  final Timestamp date;

  const MessageEntity(
      {required this.senderId,
      required this.date,
      required this.contentType,
      required this.content,
      required this.isSeen,
      required this.isEdited,
      required this.imageName});

  @override
  List<Object?> get props =>
      [senderId, date, contentType, content, isSeen, isEdited, imageName];
}

import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';

class UserChatBoxModel extends Equatable {
  final List<ChatBox> chatBoxesList;
  final List<UserModel> users;

  const UserChatBoxModel({required this.chatBoxesList, required this.users});

  @override
  List<Object> get props => [chatBoxesList, users];
}

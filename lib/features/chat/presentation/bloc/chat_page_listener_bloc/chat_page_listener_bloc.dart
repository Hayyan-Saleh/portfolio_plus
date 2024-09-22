import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/data/models/chat_box_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/listen_to_chat_box_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/listen_to_user_use_case.dart';

part 'chat_page_listener_event.dart';
part 'chat_page_listener_state.dart';

class ChatPageListenerBloc
    extends Bloc<ChatPageListenerEvent, ChatPageListenerState> {
  final ListenToChatBoxUseCase listenToChatBox;
  final ListenToUserUseCase listenToUser;

  StreamController<UserModel> userStreamController =
      StreamController<UserModel>();
  StreamController<ChatBoxModel> chatBoxStreamController =
      StreamController<ChatBoxModel>();
  ChatPageListenerBloc(
      {required this.listenToChatBox, required this.listenToUser})
      : super(ChatPageBlocInitial()) {
    on<ChatPageListenerEvent>((event, emit) async {
      if (event is ListenToUserWithChatBoxEvent) {
        emit(LoadingListeningState());
        await listenToUser(event.otherUser.id, userStreamController);
        await listenToChatBox(event.chatBox.id, chatBoxStreamController);
        userStreamController.stream.listen((changedUser) {
          add(ChangeUserStateChatPageEvent(otherUser: changedUser));
        });
        chatBoxStreamController.stream.listen((chatBox) {
          add(ChangeChatBoxChatPageEvent(chatBox: chatBox));
        });
      } else if (event is ChangeChatBoxChatPageEvent) {
        emit(ChangedChatBoxChatPageState(changedChatBox: event.chatBox));
      } else if (event is ChangeUserStateChatPageEvent) {
        emit(ChangedUserChatPageState(changedUser: event.otherUser));
      }
    });
  }
  @override
  Future<void> close() {
    // Cancel the subscription or dispose of other resources
    userStreamController.close();
    chatBoxStreamController.close();
    return super.close();
  }
}

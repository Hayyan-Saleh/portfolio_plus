// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/add_message_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/delete_message_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/modify_message_use_case.dart';

part 'chat_box_event.dart';
part 'chat_box_state.dart';

typedef MessageFunc = Future<Either<AppFailure, Unit>> Function();

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  final AddMessageUseCase addMessage;
  final DeleteMessageUseCase deleteMessage;
  final ModifyMessageUseCase modifyMessage;
  ChatBoxBloc(
      {required this.addMessage,
      required this.deleteMessage,
      required this.modifyMessage})
      : super(ChatBoxInitial()) {
    on<ChatBoxEvent>((event, emit) async {
      if (event is AddMessageEvent) {
        await _mapEither(() => addMessage(event.originalUser, event.otherUser,
            event.chatBoxId, event.message));
      } else if (event is DeleteMessageEvent) {
        await _mapEither(() => deleteMessage(event.chatBoxId, event.message));
      } else if (event is ModifyMessageEvent) {
        await _mapEither(() =>
            modifyMessage(event.chatBoxId, event.oldMessage, event.newMessage));
      }
    });
  }

  Future<void> _mapEither(MessageFunc func) async {
    emit(LoadingMessageState());
    final either = await func();
    either.fold((failure) => emit(FailedMessageState(failure: failure)),
        (_) => emit(DoneMessageState()));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/user_list_tile.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_boxes_list_bloc/chat_boxes_list_bloc.dart';
import 'package:portfolio_plus/features/chat/presentation/pages/chat_page.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class ChatAvailableUsersPage extends StatefulWidget {
  final UserModel originalUser;
  const ChatAvailableUsersPage({super.key, required this.originalUser});

  @override
  State<ChatAvailableUsersPage> createState() => _ChatAvailableUsersPageState();
}

class _ChatAvailableUsersPageState extends State<ChatAvailableUsersPage> {
  late final ChatBoxesListBloc chatBoxesListBloc;
  late final UserModel otherUser;
  @override
  void initState() {
    chatBoxesListBloc = di.sl<ChatBoxesListBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocProvider<ChatBoxesListBloc>.value(
      value: chatBoxesListBloc,
      child: BlocListener<ChatBoxesListBloc, ChatBoxesListState>(
        listener: (context, state) {
          if (state is CreatedChatBoxState) {
            BlocProvider.of<UserBloc>(context)
                .add(GetOriginalOnlineUserEvent(id: widget.originalUser.id));
            Navigator.of(context).pop();
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: ChatPage(
                    chatBox: state.createdChatBox,
                    originalUser: widget.originalUser,
                    otherUser: otherUser,
                  )),
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is LoadingFetchingOnlineUsersEvent) {
              return LoadingWidget(
                  color: Theme.of(context).colorScheme.onBackground);
            } else if (state is LoadedFollowingUserState) {
              final filteredUsers = _filterUsers(state.users);
              if (filteredUsers.isEmpty) {
                return const EmtpyDataWidget(
                    title: "No users found!",
                    subTitle: "Follow more users to chat with them");
              }
              return _getChatAvailableUsersList(context, filteredUsers);
            } else if (state is FailedUserState) {
              return FailedWidget(
                  title: "Error", subTitle: state.failure.failureMessage);
            }
            return const Center(
              child: Text("Error Occured"),
            );
          },
        ),
      ),
    );
  }

  Widget _getChatAvailableUsersList(
      BuildContext context, List<UserModel> filteredUsers) {
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) => UserListTile(
          onPressed: () {
            otherUser = filteredUsers[index];
            BlocProvider.of<ChatBoxesListBloc>(context).add(CreateChatBoxEvent(
                usersIds: [filteredUsers[index].id, widget.originalUser.id]));
          },
          user: filteredUsers[index]),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    users.removeWhere((user) {
      for (var chatId in widget.originalUser.chatIds) {
        if (user.chatIds.contains(chatId)) {
          return true;
        }
      }
      return false;
    });
    return users;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_plus/core/util/content_enum.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_box_bloc/chat_box_bloc.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_page_listener_bloc/chat_page_listener_bloc.dart';
import 'package:portfolio_plus/features/chat/presentation/widgets/chat_text_form_field.dart';
import 'package:portfolio_plus/features/chat/presentation/widgets/messageWidget.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class ChatPage extends StatefulWidget {
  final UserModel originalUser;
  final UserModel otherUser;
  final ChatBox chatBox;

  const ChatPage(
      {super.key,
      required this.otherUser,
      required this.chatBox,
      required this.originalUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<FormState> _messageFormKey = GlobalKey<FormState>();
  final TextEditingController _messageTextEditingController =
      TextEditingController();
  final ScrollController _messageScrollController = ScrollController();
  UserModel? _changedOtherUser;
  ChatBox? _changedChatBox;
  bool _showGoToLastMessageButton = false;
  bool _isEditingMessage = false;
  bool _goToMaxViewExtentOnInit = true;
  MessageEntity? _editedMessage;
  int? popupMenuValue;
  late final ChatPageListenerBloc _chatPageListenerBloc;
  late final ChatBoxBloc _chatBoxBloc;

  @override
  void initState() {
    _chatBoxBloc = di.sl<ChatBoxBloc>();
    _chatPageListenerBloc = di.sl<ChatPageListenerBloc>()
      ..add(ListenToUserWithChatBoxEvent(
          otherUser: widget.otherUser, chatBox: widget.chatBox));
    super.initState();
  }

  ScrollController _initializeController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_goToMaxViewExtentOnInit) {
        _goToMaxViewExtentOnInit = false;
        _messageScrollController.jumpTo(
          _messageScrollController.position.maxScrollExtent,
        );
      }
      _messageScrollController.addListener(_scrollListener);
    });
    return _messageScrollController;
  }

  void _scrollListener() {
    final currentPosition = _messageScrollController.position.pixels;
    final maxScrollExtent = _messageScrollController.position.maxScrollExtent;
    if (currentPosition < maxScrollExtent) {
      setState(() {
        _showGoToLastMessageButton = true;
      });
    } else {
      setState(() {
        _showGoToLastMessageButton = false;
      });
    }
  }

  @override
  void dispose() {
    _messageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatPageListenerBloc>(
          create: (context) => _chatPageListenerBloc,
        ),
        BlocProvider<ChatBoxBloc>(
          create: (context) => _chatBoxBloc,
        )
      ],
      child: BlocListener<ChatPageListenerBloc, ChatPageListenerState>(
        listener: (context, state) {
          if (state is ChangedUserChatPageState) {
            _changedOtherUser = state.changedUser;
          } else if (state is ChangedChatBoxChatPageState) {
            _changedChatBox = state.changedChatBox;
          }
        },
        child: SafeArea(
          child: Scaffold(
            body: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    final double height = getHeight(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
            height: 0.08 * height, child: _buildAppBarBloc(context, height)),
        Expanded(
          child: _buildMessagesSection(context, height),
        ),
        SizedBox(
            height: 0.1 * height,
            child: _buildSendMessageSection(context, height)),
      ],
    );
  }

  Widget _buildSendMessageSection(BuildContext context, double height) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: widget.originalUser.isDarkMode!
              ? Colors.grey[900]
              : Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Row(
        children: [
          Expanded(
            child: ChatTextFormField(
                formkey: _messageFormKey,
                textEditingController: _messageTextEditingController,
                errorMessage: "please enter a message to send",
                hintText: 'Enter a message'),
          ),
          _buildSendButtonBloc(context),
        ],
      ),
    );
  }

  Widget _buildSendButtonBloc(BuildContext context) {
    return BlocBuilder<ChatBoxBloc, ChatBoxState>(
      builder: (context, state) {
        if (state is LoadingMessageState) {
          return Center(
            child: Container(
              height: 25,
              width: 25,
              margin: const EdgeInsets.all(10),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        } else if (state is DoneMessageState) {
          _showGoToLastMessageButton = false;
        }
        return _buildSendButton(context);
      },
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (_messageFormKey.currentState!.validate()) {
            if (_isEditingMessage && _editedMessage != null) {
              BlocProvider.of<ChatBoxBloc>(context).add(ModifyMessageEvent(
                  chatBoxId: widget.chatBox.id,
                  oldMessage: _editedMessage!,
                  newMessage: createEditedMessage(
                      message: _editedMessage!,
                      newData: _messageTextEditingController.text)));
              _messageTextEditingController.text = '';
              _isEditingMessage = false;
              _editedMessage = null;
            } else if (!_isEditingMessage) {
              BlocProvider.of<ChatBoxBloc>(context).add(AddMessageEvent(
                originalUser: widget.originalUser,
                otherUser: widget.otherUser,
                chatBoxId: widget.chatBox.id,
                message: _createMessage(),
              ));
              _messageTextEditingController.text = '';
            }
          }
        },
        icon: _isEditingMessage
            ? Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary.withAlpha(200),
              )
            : Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary.withAlpha(200),
              ));
  }

  Widget _buildMessagesSection(BuildContext context, double height) {
    return Stack(
      children: [
        _buildMessagesBloc(context, height),
        if (_showGoToLastMessageButton)
          Positioned(right: 5, bottom: 5, child: _buildGoToLastMessageButton())
      ],
    );
  }

  Widget _buildMessagesBloc(BuildContext context, double height) {
    return BlocBuilder<ChatPageListenerBloc, ChatPageListenerState>(
      builder: (context, state) {
        return _changedChatBox == null
            ? _buildMessages(context, widget.chatBox, height)
            : _buildMessages(context, _changedChatBox!, height);
      },
    );
  }

  Widget _buildMessages(BuildContext context, ChatBox chatBox, double height) {
    if (chatBox.messages.isEmpty) {
      return const EmtpyDataWidget(
          title: "NO Messages", subTitle: "Say hello to your friend!");
    }
    final List<Widget> messagesWithDates =
        _buildMessagesWithDates(chatBox.messages);
    return ListView.builder(
      controller: _initializeController(),
      itemCount: messagesWithDates.length,
      itemBuilder: (context, index) => messagesWithDates[index],
    );
  }

  BlocBuilder<ChatPageListenerBloc, ChatPageListenerState> _buildAppBarBloc(
      BuildContext context, double height) {
    return BlocBuilder<ChatPageListenerBloc, ChatPageListenerState>(
      builder: (context, state) {
        if (_changedOtherUser == null) {
          return _buildAppBar(context, widget.otherUser, height);
        } else {
          return _buildAppBar(context, _changedOtherUser!, height);
        }
      },
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel user, double height) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.secondaryContainer
      ])),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              )),
          Padding(
            padding:
                const EdgeInsets.only(right: 10, left: 0, top: 10, bottom: 10),
            child: Container(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(200),
              width: 2,
            ),
          ),
          Row(
            children: [
              if (user.profilePictureUrl != null)
                CustomCachedNetworkImage(
                    isRounded: true,
                    height: 0.3 * height,
                    imageUrl: user.profilePictureUrl!),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getFirstName(user.userName!),
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  !user.isOffline!
                      ? Text(
                          "Online",
                          style: TextStyle(
                              color: widget.originalUser.isDarkMode!
                                  ? Colors.greenAccent
                                  : const Color.fromARGB(255, 0, 148, 5),
                              fontSize: 16),
                        )
                      : Text(
                          getLastSeenTimeString(user.lastSeenTime),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withAlpha(150)),
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoToLastMessageButton() {
    return MaterialButton(
      shape: const CircleBorder(side: BorderSide()),
      onPressed: () => _goToLastMessage(),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Icon(Icons.arrow_downward),
    );
  }

  MessageEntity _createMessage() {
    return MessageEntity(
        senderId: widget.originalUser.id,
        date: Timestamp.now(),
        contentType: Content.text.type,
        content: _messageTextEditingController.text,
        isSeen: false,
        isEdited: false);
  }

  void _goToLastMessage() {
    _messageScrollController.animateTo(
      _messageScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _setSeenMessage(MessageEntity message) {
    _chatBoxBloc.add(ModifyMessageEvent(
        chatBoxId: widget.chatBox.id,
        oldMessage: message,
        newMessage: createSeenMessage(message: message)));
  }

  List<PopupMenuItem<int>> _getPopupMenuItems(
      BuildContext context, MessageEntity message, bool isOriginalUserMessage) {
    return [
      if (isOriginalUserMessage)
        const PopupMenuItem<int>(
          value: 1,
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
      if (isOriginalUserMessage)
        const PopupMenuItem<int>(
          value: 2,
          child: Text(
            "Modify",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      if (message.contentType == Content.text.type)
        const PopupMenuItem<int>(
          value: 3,
          child: Text('Copy Text'),
        ),
    ];
  }

  void _onMenuItemSelected(
      BuildContext context, int value, MessageEntity message) {
    switch (value) {
      case 1:
        _chatBoxBloc.add(DeleteMessageEvent(
          chatBoxId: widget.chatBox.id,
          message: message,
        ));
        break;
      case 2:
        _messageTextEditingController.text = message.content;
        setState(() {
          _isEditingMessage = true;
          _editedMessage = message;
        });
        break;
      case 3:
        Clipboard.setData(ClipboardData(text: message.content));
        showToastMessage(context, "Copied to clipboard", null);
        break;
    }
  }

  Widget _createPopUpMenuButton(
      BuildContext context, MessageEntity message, bool isOriginalUserMessage) {
    if (!isOriginalUserMessage && !message.isSeen) {
      _setSeenMessage(message);
    }
    return PopupMenuButton(
      itemBuilder: (context) =>
          _getPopupMenuItems(context, message, isOriginalUserMessage),
      onSelected: (value) => _onMenuItemSelected(context, value, message),
      child: MessageWidget(
        isOriginalUserMessage: isOriginalUserMessage,
        message: message,
      ),
    );
  }

  bool _isOriginalMessage(MessageEntity message) {
    return widget.originalUser.id == message.senderId;
  }

  List<Widget> _buildMessagesWithDates(List<MessageEntity> messages) {
    if (messages.isNotEmpty) {
      List<Widget> widgets = [];
      widgets.add(_createDateWidget(messages[0].date));
      for (int i = 0; i < messages.length; i++) {
        if (i > 0) {
          final firstMessageDay = messages[i - 1].date.toDate().day;
          final secondMessageDay = messages[i].date.toDate().day;
          if (firstMessageDay != secondMessageDay) {
            widgets.add(_createDateWidget(messages[i].date));
          }
        }
        widgets.add(_createPopUpMenuButton(
            context, messages[i], _isOriginalMessage(messages[i])));
      }
      return widgets;
    }
    return [];
  }

  Center _createDateWidget(Timestamp timestamp) {
    DateTime messageDate = timestamp.toDate();
    DateTime currentTimeDate = DateTime.now();
    String monthName = DateFormat('MMM').format(messageDate);
    String dateText = "$monthName ${messageDate.day}";
    if (messageDate.day == currentTimeDate.day) {
      dateText = "Today";
    } else if (messageDate.day == currentTimeDate.day - 1) {
      dateText = "Yesterday";
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        alignment: Alignment.center,
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color:
                    Theme.of(context).colorScheme.onBackground.withAlpha(50)),
            child: Text(dateText)),
      ),
    );
  }
}

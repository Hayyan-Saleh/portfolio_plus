import 'package:flutter/material.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';

class ChatListTile extends StatelessWidget {
  final UserModel user;
  final ChatBox chatBox;
  final Function() onPressed;
  const ChatListTile(
      {super.key,
      required this.onPressed,
      required this.user,
      required this.chatBox});

  @override
  Widget build(BuildContext context) {
    final double height = getHeight(context);
    return Row(
      children: [
        Expanded(
            child: InkWell(
          onTap: () => onPressed(),
          child: Row(children: [
            Padding(
              padding: EdgeInsets.all(0.02 * height),
              child: _buildProfilePicture(height),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      user.userName!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  Text(
                    user.isOffline!
                        ? getLastSeenTimeString(user.lastSeenTime)
                        : "online",
                    style: TextStyle(
                      color: user.isOffline!
                          ? Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(150)
                          : const Color.fromARGB(255, 0, 224, 93),
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  chatBox.lastMessage != null
                      ? Text(
                          "${chatBox.lastMessage!.senderId == user.id ? getFirstName(user.userName!) : "You "}: ${_getMessageContent()}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        )
                      : Text(
                          "No messages yet",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                ],
              ),
            ),
          ]),
        ))
      ],
    );
  }

  Widget _buildProfilePicture(double height) {
    return Stack(
      children: [
        user.profilePictureUrl == null
            ? DefaultProfilePicture(height: 0.30 * height)
            : CircleAvatar(
                radius: 0.035 * height,
                child: CustomCachedNetworkImage(
                    height: 0.33 * height,
                    imageUrl: user.profilePictureUrl!,
                    isRounded: true),
              ),
        Positioned(
          bottom: 0,
          right: 5,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: user.isOffline!
                  ? Colors.grey
                  : Colors.green, // Online status color
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        )
      ],
    );
  }

  String _getMessageContent() {
    return chatBox.lastMessage!.contentType == IMAGE_CONTENT_TYPE
        ? "Picture"
        : chatBox.lastMessage!.content;
  }
}

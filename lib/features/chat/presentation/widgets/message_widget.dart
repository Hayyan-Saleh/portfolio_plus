import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/show_image_page.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final bool isOriginalUserMessage;
  final MessageEntity message;
  const MessageWidget({
    super.key,
    required this.isOriginalUserMessage,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _handelAligment(context);
  }

  Widget _handelAligment(BuildContext context) {
    if (isOriginalUserMessage) {
      return Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: IntrinsicWidth(child: _buildOriginalUserMessage(context)),
      );
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: IntrinsicWidth(child: _buildOtherUserMessage(context)),
      );
    }
  }

  Widget _buildOtherUserMessage(BuildContext context) {
    final DateTime messageDate = message.date.toDate();
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            message.contentType == IMAGE_CONTENT_TYPE
                ? _buildImageContent(context)
                : _buildTextContent(context),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  message.isSeen ? Icons.done_all : Icons.done,
                  color: message.isSeen
                      ? Colors.blue
                      : Theme.of(context).colorScheme.background.withAlpha(150),
                  size: 15,
                ),
                Text(
                  DateFormat(' hh:mm a').format(messageDate),
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withAlpha(150)),
                ),
                if (message.isEdited)
                  Text(
                    " Edited",
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withAlpha(150)),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalUserMessage(BuildContext context) {
    final DateTime messageDate = message.date.toDate();
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            message.contentType == IMAGE_CONTENT_TYPE
                ? _buildImageContent(context)
                : _buildTextContent(context),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  message.isSeen ? Icons.done_all : Icons.done,
                  color: message.isSeen
                      ? Colors.blue
                      : Theme.of(context).colorScheme.background.withAlpha(150),
                  size: 15,
                ),
                Text(
                  DateFormat(' hh:mm a').format(messageDate),
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withAlpha(150)),
                ),
                if (message.isEdited)
                  Text(
                    " Edited",
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withAlpha(150)),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Text(
      message.content,
      textAlign: TextAlign.end,
      overflow: TextOverflow.clip,
      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: ShowImagePage(
                    pictureUrl: message.content,
                  )));
        },
        child: CustomCachedNetworkImage(
          imageUrl: message.content,
          isRounded: false,
          height: 0.25 * getHeight(context),
        ));
  }
}

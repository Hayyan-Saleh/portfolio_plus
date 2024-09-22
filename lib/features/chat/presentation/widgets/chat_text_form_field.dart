import 'package:flutter/material.dart';

class ChatTextFormField extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final TextEditingController textEditingController;
  final String hintText, errorMessage;
  final FocusNode focusNode;
  const ChatTextFormField(
      {required this.formkey,
      required this.textEditingController,
      required this.errorMessage,
      required this.hintText,
      required this.focusNode,
      super.key});

  @override
  State<ChatTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<ChatTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: TextFormField(
        focusNode: widget.focusNode,
        cursorColor: Theme.of(context).colorScheme.secondary,
        autocorrect: true,
        controller: widget.textEditingController,
        validator: (val) {
          if (val == null || val == '') {
            return widget.errorMessage;
          }
          return null;
        },
        maxLines: 5,
        minLines: 1,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            errorStyle: const TextStyle(color: Colors.red),
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary.withAlpha(150)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary)),
            hintText: widget.hintText,
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary))),
      ),
    );
  }
}

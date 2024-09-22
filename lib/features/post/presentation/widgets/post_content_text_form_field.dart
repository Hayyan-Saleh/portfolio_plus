import 'package:flutter/material.dart';

class PostContentTextFormField extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final TextEditingController textEditingController;
  final String hintText, errorMessage;
  const PostContentTextFormField(
      {required this.formkey,
      required this.textEditingController,
      required this.errorMessage,
      required this.hintText,
      super.key});

  @override
  State<PostContentTextFormField> createState() =>
      _PostContentTextFormFieldState();
}

class _PostContentTextFormFieldState extends State<PostContentTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: TextFormField(
        cursorColor: Theme.of(context).colorScheme.secondary,
        maxLines: 6,
        autocorrect: false,
        controller: widget.textEditingController,
        validator: (val) {
          if (val == null || val == '') {
            return widget.errorMessage;
          }
          return null;
        },
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        decoration: InputDecoration(
            errorStyle: const TextStyle(color: Colors.red),
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary.withAlpha(150)),
            enabledBorder: OutlineInputBorder(
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

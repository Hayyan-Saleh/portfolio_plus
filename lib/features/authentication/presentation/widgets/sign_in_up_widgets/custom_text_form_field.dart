import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final TextEditingController textEditingController;
  final String hintText, errorMessage;
  final bool obsecure;
  const CustomTextFormField(
      {required this.formkey,
      required this.obsecure,
      required this.textEditingController,
      required this.errorMessage,
      required this.hintText,
      super.key});

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: TextFormField(
        cursorColor: Theme.of(context).colorScheme.secondary,
        obscureText: widget.obsecure,
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

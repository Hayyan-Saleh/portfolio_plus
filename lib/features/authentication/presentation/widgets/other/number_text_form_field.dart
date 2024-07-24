import 'package:flutter/material.dart';

class NumberTextFormField extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final TextEditingController textEditingController;
  final String hintText;
  const NumberTextFormField(
      {required this.formkey,
      required this.textEditingController,
      required this.hintText,
      super.key});

  @override
  State<NumberTextFormField> createState() => _NumberTextFormFieldState();
}

class _NumberTextFormFieldState extends State<NumberTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: TextFormField(
        cursorColor: Theme.of(context).colorScheme.secondary,
        keyboardType: TextInputType.number,
        autocorrect: false,
        controller: widget.textEditingController,
        validator: (val) {
          if (val == null || val == '') {
            return "Please enter a number";
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

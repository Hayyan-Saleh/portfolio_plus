import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';

class CustomUserAccountNameTextField extends StatefulWidget {
  final UserAccountNameBloc userAccountNameBloc;
  final GlobalKey<FormState> formKey;
  final TextEditingController textEditingController;
  final String hintText;
  const CustomUserAccountNameTextField({
    super.key,
    required this.userAccountNameBloc,
    required this.hintText,
    required this.formKey,
    required this.textEditingController,
  });

  @override
  State<CustomUserAccountNameTextField> createState() =>
      _CustomUserAccountNameTextFieldState();
}

class _CustomUserAccountNameTextFieldState
    extends State<CustomUserAccountNameTextField> {
  String? errorMessage;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserAccountNameBloc>(
      create: (context) => widget.userAccountNameBloc,
      child: Form(
        onChanged: () {
          widget.formKey.currentState!.validate();
        },
        key: widget.formKey,
        child: TextFormField(
          controller: widget.textEditingController,
          validator: (val) {
            if (val == '' || val == null) {
              errorMessage = "Please enter an account name";
            } else {
              widget.userAccountNameBloc
                  .add(CheckUserAccountNameEvent(accountName: val));
            }

            return errorMessage;
          },
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          decoration: InputDecoration(
              suffix: BlocBuilder<UserAccountNameBloc, UserAccountNameState>(
                builder: (context, state) {
                  Widget widget = const SizedBox();
                  if (state is UserAccountNameLoadingState) {
                    widget = SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,
                          color: Theme.of(context).colorScheme.secondary,
                        ));
                  } else if (state is UserAccountNameCheckedState) {
                    widget = _buildIcon(state.isVerified);
                    if (!state.isVerified) {
                      errorMessage = state.message;
                    } else {
                      errorMessage = null;
                    }
                  }
                  return widget;
                },
              ),
              errorStyle: const TextStyle(color: Colors.red),
              hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withAlpha(150)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary)),
              hintText: widget.hintText,
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary))),
        ),
      ),
    );
  }

  Widget _buildIcon(bool status) {
    return widget.textEditingController.text == ''
        ? const Icon(Icons.error_outline_outlined, color: Colors.red)
        : Icon(status ? Icons.done : Icons.error_outline_outlined,
            color: status ? Colors.green : Colors.red);
  }
}

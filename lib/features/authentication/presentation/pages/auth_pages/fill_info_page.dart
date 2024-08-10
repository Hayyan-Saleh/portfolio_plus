import 'dart:io';

import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/constants/maps.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/util/gender_enum.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/custom_seperator.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_profile_picture_bloc/user_profile_picture_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/home_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/custom_user_account_name_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/drop_down_button.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/number_text_form_field.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_button.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/sign_in_up_widgets/custom_text_form_field.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class FillInfoPage extends StatefulWidget {
  final UserModel userModel;
  final UserProfilePictureBloc userProfilePictureBloc;
  final UserAccountNameBloc userAccountNameBloc;
  final UserBloc userBloc;
  final AuthenticationBloc authBloc;

  const FillInfoPage(
      {super.key,
      required this.userProfilePictureBloc,
      required this.userBloc,
      required this.authBloc,
      required this.userModel,
      required this.userAccountNameBloc});

  @override
  State<FillInfoPage> createState() => _FillInfoPageState();
}

class _FillInfoPageState extends State<FillInfoPage> {
  final GlobalKey<FormState> userNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> accountNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneNumberFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> userEmailFormKey = GlobalKey<FormState>();
  final TextEditingController userNameEditingController =
      TextEditingController();
  final TextEditingController accountNameEditingController =
      TextEditingController();
  final TextEditingController phoneNumberEditingController =
      TextEditingController();
  final TextEditingController userEmailEditingController =
      TextEditingController();

  String? imageDownloadLink;
  String? selectedGender;
  Timestamp? birthDate;
  String? countryCode;
  @override
  void dispose() {
    userEmailEditingController.dispose();
    phoneNumberEditingController.dispose();
    accountNameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>.value(
      value: widget.userBloc,
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          double height = MediaQuery.of(context).size.height;
          double width = MediaQuery.of(context).size.width;
          Widget stateWidget =
              LoadingWidget(color: Theme.of(context).colorScheme.secondary);
          if (state is LaodedOnlineUserState) {
            stateWidget = _buildBody(context, state.user, height, width,
                widget.userProfilePictureBloc);
          } else if (state is StoredOnlineUserState) {
            stateWidget = _buildBody(context, state.user, height, width,
                widget.userProfilePictureBloc);
          } else if (state is FailedUserState) {
            showCustomAboutDialog(context, "User Error !",
                state.failure.failureMessage, null, true);
          }
          return SafeArea(
            child: Scaffold(
              appBar: buildAppBar(context),
              backgroundColor: Theme.of(context).colorScheme.background,
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.02 * height),
                child: Center(child: stateWidget),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserModel userModel, double height,
      double width, UserProfilePictureBloc userProfilePictureBloc) {
    return ListView(
      children: [
        SizedBox(
          height: 0.01 * height,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.01 * height),
          child: _buildProfilePictureWidget(
              context, height, userProfilePictureBloc),
        ),
        _buildHeadingText(context, "Upload a profile picture", true, true),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.03 * height),
          child: CustomSeperator(height: 0.004 * height, width: 0.3 * width),
        ),
        _buildHeadingText(context, "Enter your user name", false, false),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.01 * height),
          child: CustomTextFormField(
              formkey: userNameFormKey,
              obsecure: false,
              textEditingController: userNameEditingController,
              errorMessage: "Please enter your real name here",
              hintText: ""),
        ),
        _buildHeadingText(context, "Enter your account name", false, false),
        SizedBox(
          height: 0.01 * height,
        ),
        CustomUserAccountNameTextField(
            userAccountNameBloc: widget.userAccountNameBloc,
            hintText: "example: user_name_1023",
            formKey: accountNameFormKey,
            textEditingController: accountNameEditingController),
        SizedBox(
          height: 0.005 * height,
        ),
        _buildDetailsText(context, "The account name must be unique", 12),
        SizedBox(
          height: 0.01 * height,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.01 * height),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeadingText(context, "Choose your gender", false, false),
              _buildChooseGenderWidget(context)
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHeadingText(context, "Choose your birth date", false, false),
            _buildChooseBirthDateButton(context)
          ],
        ),
        if (birthDate != null)
          _buildDetailsText(
              context,
              "Your selected birth date is :  ${birthDate!.toDate().day} / ${birthDate!.toDate().month} / ${birthDate!.toDate().year}",
              14),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.03 * height),
          child: CustomSeperator(height: 0.004 * height, width: 0.3 * width),
        ),
        SizedBox(
          height: 0.01 * height,
        ),
        _buildHeadingText(context, "Enter your phone number", false, false),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.01 * height),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 0.06 * height,
                width: 0.25 * width,
                child: CustomDropDownButton(
                  dropDownTitle: "Choose your country code",
                  buttonTitle: countryCode == null
                      ? "Country code"
                      : '+ ${countryCodeMap[countryCode]!}',
                  dataList: countryCodeMap.keys.toList(),
                  onSelect: (List<dynamic> selectedList) {
                    for (var item in selectedList) {
                      if (item is SelectedListItem) {
                        showSnackBar(context, "${item.name} is selected",
                            const Duration(seconds: 2));
                        setState(() {
                          countryCode = item.name;
                        });
                      }
                    }
                  },
                ),
              ),
              SizedBox(
                width: 0.05 * width,
              ),
              SizedBox(
                height: 0.06 * height,
                width: 0.6 * width,
                child: NumberTextFormField(
                    formkey: phoneNumberFormKey,
                    textEditingController: phoneNumberEditingController,
                    hintText: "Enter your mobile number "),
              )
            ],
          ),
        ),
        if (userModel.email == 'temp email' || userModel.email == '')
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.01 * height),
            child: Column(
              children: [
                _buildHeadingText(
                    context, "Enter your contact email ", true, false),
                SizedBox(
                  height: 0.01 * height,
                ),
                CustomTextFormField(
                    formkey: userEmailFormKey,
                    obsecure: false,
                    textEditingController: userEmailEditingController,
                    errorMessage: "no error",
                    hintText: "user_email@gmail.com")
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.03 * height),
          child: CustomSeperator(height: 0.004 * height, width: 0.3 * width),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 0.02 * height),
          child: CustomAuthButton(
              icon: Icons.keyboard_double_arrow_right_outlined,
              onTap: () => _goToHomeScreenOnTap(),
              child: Text(
                "Go To Home Screen",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.background,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )),
        ),
      ],
    );
  }

  Widget _buildHeadingText(
      BuildContext context, String text, bool isOptional, bool isCenter) {
    return Row(
      mainAxisAlignment:
          isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(
          width: 5,
        ),
        isOptional
            ? Text(
                "(optional)",
                overflow: TextOverflow.clip,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary),
              )
            : const SizedBox()
      ],
    );
  }

  Widget _buildDetailsText(BuildContext context, String text, double size) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size, color: Theme.of(context).colorScheme.secondary),
    );
  }

  Widget _buildProfilePictureWidget(BuildContext context, double height,
      UserProfilePictureBloc userProfilePictureBloc) {
    return BlocProvider<UserProfilePictureBloc>(
      create: (context) => userProfilePictureBloc,
      child: BlocBuilder<UserProfilePictureBloc, UserProfilePictureState>(
        builder: (context, state) {
          bool clickable = true;
          Widget stateWidget = CircleAvatar(
              radius: 0.1 * height,
              backgroundColor:
                  Theme.of(context).colorScheme.onPrimary.withAlpha(150),
              child: Icon(
                Icons.add_a_photo_outlined,
                size: 0.07 * height,
                color: Theme.of(context).colorScheme.primary,
              ));
          if (state is LoadingUserProfilePhotoState) {
            clickable = false;
            stateWidget = CircleAvatar(
              radius: 0.1 * height,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.background,
              ),
            );
          } else if (state is LoadedUserProfilePhotoState) {
            clickable = false;
            imageDownloadLink = state.downloadLink;
            stateWidget = CustomCachedNetworkImage(
                isRounded: true, height: height, imageUrl: state.downloadLink);
          } else if (state is FailedLoadingPictureState) {
            clickable = true;
            showCustomAboutDialog(
                context, "Online Fetch Error", state.errorMessage, null, true);
          }
          return GestureDetector(
              onTap: clickable
                  ? () async {
                      if (!widget.userBloc.isClosed) {
                        File? imageFile = await getImage();
                        if (imageFile != null) {
                          userProfilePictureBloc.add(StoreUserProfilePhotoEvent(
                              userId: widget.userModel.id, file: imageFile));
                        }
                      }
                    }
                  : null,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                radius: 0.105 * height,
                child: Center(child: stateWidget),
              ));
        },
      ),
    );
  }

  Widget _buildChooseGenderWidget(BuildContext context) {
    final List genders = Gender.values.map<String>((e) => e.name).toList();
    return PopupMenuButton(
      color: Theme.of(context).colorScheme.secondary,
      onSelected: (value) {
        setState(() {
          selectedGender = genders[value];
        });
      },
      shadowColor: Theme.of(context).colorScheme.onSecondary,
      itemBuilder: (context) {
        return <PopupMenuItem>[
          ...List.generate(
              genders.length,
              (index) => PopupMenuItem(
                    value: index,
                    child: Text(
                      genders.elementAt(index),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                  ))
        ];
      },
      iconColor: Theme.of(context).colorScheme.onSecondary,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.secondary),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(selectedGender ?? "Select",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSecondary)),
              Icon(Icons.arrow_drop_down_sharp,
                  color: Theme.of(context).colorScheme.onSecondary)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChooseBirthDateButton(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        showDatePicker(
          context: context,
          firstDate: DateTime(1980),
          lastDate: DateTime(2020),
        ).then((value) {
          setState(() {
            birthDate = dateTimeToTimestamp(value!);
          });
        });
      },
      color: Theme.of(context).colorScheme.secondary,
      child: Text("Choose",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSecondary)),
    );
  }

  void _goToHomeScreenOnTap() {
    if (userNameFormKey.currentState!.validate() &&
        accountNameFormKey.currentState!.validate() &&
        selectedGender != null &&
        birthDate != null &&
        countryCode != null &&
        phoneNumberFormKey.currentState!.validate()) {
      final createdUser = _createFilledInfoUser();
      widget.userBloc.add(StoreOnlineUserEvent(user: createdUser));
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: HomePage(
              userAccountNameBloc: widget.userAccountNameBloc,
              userProfilePictureBloc: widget.userProfilePictureBloc,
              searchUsersBloc: di.sl<SearchUsersBloc>(),
              userBloc: widget.userBloc,
              authBloc: widget.authBloc,
              user: createdUser),
        ),
        (route) => false,
      );
    } else {
      showCustomAboutDialog(context, "Error",
          "Please fill all the required data in order to continue", null, true);
    }
  }

  UserModel _createFilledInfoUser() {
    return UserModel(
        accountName: accountNameEditingController.text.trim(),
        authenticationType: widget.userModel.authenticationType,
        birthDate: birthDate,
        chatIds: [],
        email: userEmailEditingController.text.trim(),
        followersIds: [],
        followingIds: [],
        gender: selectedGender,
        id: widget.userModel.id,
        isDarkMode: widget.userModel.isDarkMode,
        isOffline: false,
        lastSeenTime: Timestamp.now(),
        phoneNumber:
            "+ ${countryCodeMap[countryCode]} ${phoneNumberEditingController.text}",
        profilePictureUrl: imageDownloadLink,
        savedPostsIds: [],
        userName: userNameEditingController.text.trim(),
        userPostsIds: []);
  }
}
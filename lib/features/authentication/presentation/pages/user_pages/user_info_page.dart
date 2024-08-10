import 'package:flutter/material.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

class UserInfoPage extends StatelessWidget {
  final UserModel user;
  const UserInfoPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return ListView(
      children: [
        SizedBox(
            height: 0.25 * height,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 0.02 * width, vertical: 0.05 * height),
              child: _buildContainer(
                  context,
                  height * 0.2,
                  width,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildBasicUserInfo(context, height),
                  )),
            )),
        SizedBox(
            height: 0.55 * height,
            child: _buildContainer(context, 0.7 * height, width,
                _buildUserOtherInfo(context, height, width)))
      ],
    );
  }

  Widget _buildContainer(
      BuildContext context, double height, double width, Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.02 * width),
      child: Container(
        height: height,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                  blurRadius: 5,
                  spreadRadius: 3)
            ],
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            color: Theme.of(context).colorScheme.secondary.withAlpha(50)),
        child: child,
      ),
    );
  }

  Widget _buildUserOtherInfo(
      BuildContext context, double height, double width) {
    return ListView(
      children: [
        SizedBox(
          height: 0.02 * height,
        ),
        SizedBox(
            height: 0.1 * height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
              child: _buildColumn(context, "Projects count :",
                  user.userPostsIds.length.toString()),
            )),
        SizedBox(
            height: 0.1 * height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
              child:
                  _buildColumn(context, "Gender :", user.gender ?? "Not found"),
            )),
        SizedBox(
            height: 0.1 * height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
              child: _buildColumn(
                  context, "Phone number :", user.phoneNumber ?? "Not found"),
            )),
        if (user.email != '')
          SizedBox(
              height: 0.1 * height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
                child: _buildColumn(context, "Contact email :", user.email!),
              )),
        SizedBox(
          height: 0.1 * height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
            child: _buildColumn(context, "Birth date :",
                "${user.birthDate!.toDate().year} / ${user.birthDate!.toDate().month} / ${user.birthDate!.toDate().day}"),
          ),
        )
      ],
    );
  }

  Widget _buildColumn(
      BuildContext context, String firstData, String secondData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstData,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        SelectableText(
          secondData,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildBasicUserInfo(BuildContext context, double height) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 0.05 * height,
          child: Center(
            child: user.profilePictureUrl != null
                ? CustomCachedNetworkImage(
                    isRounded: true,
                    height: 0.47 * height,
                    imageUrl: user.profilePictureUrl!)
                : DefaultProfilePicture(height: 0.8 * height),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName ?? "No user name found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  user.accountName ?? "No acccount name found",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SingleChildScrollView(
          child: _buildInfoWidget(context),
        ),
        _buildUrlButtonsWidget(context)
      ],
    );
  }

  Widget _buildUrlButtonsWidget(BuildContext context) {
    return Hero(
      tag: "navigation_to_about_page",
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildUrlButton("f", "https://www.facebook.com/hayyan.saleh.940",
                const Color.fromARGB(255, 226, 242, 255), Colors.blue),
            _buildUrlButton("GitHub", "https://github.com/Hayyan-Saleh",
                const Color.fromARGB(255, 186, 0, 177), Colors.white),
            _buildUrlButton(
                "in",
                "https://www.linkedin.com/in/hayyan-saleh-6476b1267/",
                const Color.fromARGB(255, 9, 93, 161),
                Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ])),
      child: const Column(
        children: [
          SizedBox(height: 30),
          Text(
            "About the application",
            style: TextStyle(
                color: Color.fromARGB(255, 232, 232, 232),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              "This application aimes to provide the required aid for people who want to share their achievments on a collaborative platform with others through : posting, chatting & following other users  \n\nThis Project was done by Hayyan Saleh! \n\nMy accounts can be accessed by clicking any Icon below to open the URL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  MaterialButton _buildUrlButton(
      String name, String url, Color backgroundColor, Color foregroundColor) {
    return MaterialButton(
      elevation: 10,
      onPressed: () async {
        await _launchUrl(url);
      },
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
      child: Text(
        name,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final parsedUrl = Uri.parse(url);
    try {
      await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
      // ignore: empty_catches
    } catch (e) {}
  }
}

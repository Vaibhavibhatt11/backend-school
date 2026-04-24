import 'package:flutter/material.dart';
import '../common/theme/app_color.dart';
import 'common_app_bar.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showProfileIcon = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
  });

  final String title;
  final Widget body;
  final bool showProfileIcon;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: CommonAppBar(
        title: title,
        showBackButton: true,
        showProfileIcon: showProfileIcon,
      ),
      body: SafeArea(child: body),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

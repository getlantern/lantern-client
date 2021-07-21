import 'package:flutter/material.dart';
import 'package:lantern/package_store.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final String? logoTitle;
  final List<Widget>? actions;
  final Widget body;
  final Widget? actionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  BaseScreen(
      {this.title = '',
      this.logoTitle,
      this.actions,
      required this.body,
      this.actionButton,
      this.floatingActionButtonLocation,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: title,
        logoTitle: logoTitle,
        actions: actions,
      ),
      body: body,
      floatingActionButton: actionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

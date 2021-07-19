import 'package:flutter/material.dart';
import 'package:lantern/package_store.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final String? logoTitle;
  final List<Widget>? actions;
  final Widget body;
  final Widget? actionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? centerTitle;

  BaseScreen(
      {this.title = '',
      this.logoTitle,
      this.actions,
      required this.body,
      this.actionButton,
      this.floatingActionButtonLocation,
      this.centerTitle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: title,
        logoTitle: logoTitle,
        centerTitle: centerTitle,
        actions: actions,
      ),
      body: body,
      floatingActionButton: actionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

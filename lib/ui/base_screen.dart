import 'package:flutter/material.dart';
import 'package:lantern/package_store.dart';

class BaseScreen extends StatefulWidget {
  final String title;
  final String logoTitle;
  final List<Widget> actions;
  final Widget body;
  BaseScreen({this.title, this.logoTitle, this.actions, this.body, Key key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.title,
        logoTitle: widget.logoTitle,
        actions: widget.actions,
      ),
      body: widget.body,
    );
  }

  @override
  // prevent to re-render
  bool get wantKeepAlive => true;
}

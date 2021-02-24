import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import 'messages.dart';
import 'vpn.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          children: [
            MessagesTab(),
            VPNTab(),
            Text("Need to build this"),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(text: 'Messages'.i18n, icon: Icon(Icons.mail_rounded)),
            Tab(text: 'VPN'.i18n, icon: Icon(Icons.vpn_key)),
            Tab(text: 'Account'.i18n, icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}

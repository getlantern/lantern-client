import 'package:flutter/material.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/ui/index.dart';

class MessagingScreen extends StatelessWidget {
  final Contact contact;

  const MessagingScreen({required this.contact});

  @override
  Widget build(BuildContext context) => BaseScreen(
        title: contact.displayName.isEmpty
            ? contact.contactId.id
            : contact.displayName,
        body: Container(),
      );
}

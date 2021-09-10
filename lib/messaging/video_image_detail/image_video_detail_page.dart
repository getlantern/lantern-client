import 'package:flutter/material.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class ImageVideoDetailPage extends StatefulWidget {
  final ContactId contactId;

  const ImageVideoDetailPage({Key? key, required this.contactId})
      : super(key: key);

  @override
  _ImageVideoDetailPageState createState() => _ImageVideoDetailPageState();
}

class _ImageVideoDetailPageState extends State<ImageVideoDetailPage> {
  @override
  Widget build(BuildContext context) {
    MessagingModel model;
    model = context.watch<MessagingModel>();
    return model.singleContactById(context, widget.contactId,
        (context, contact, child) {
      return BaseScreen(
          title: contact.displayName.isEmpty
              ? contact.contactId.id
              : contact.displayName,
          body: Text('TERI TERI'));
    });
  }
}

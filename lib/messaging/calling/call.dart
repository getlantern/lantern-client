import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/calling/signaling.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class Call extends StatefulWidget {
  final Contact _contact;
  final MessagingModel _model;

  Call(this._contact, this._model) : super();

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> {
  late Session session;

  @override
  void initState() {
    super.initState();
    widget._model.signaling
        .call(widget._contact.contactId.id, 'audio')
        .then((newSession) {
      session = newSession;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget._model.signaling.bye(session);
        Navigator.of(context, rootNavigator: true).pop();
      },
      child: Text(
        "Go Back",
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

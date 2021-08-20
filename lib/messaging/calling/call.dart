import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/calling/signaling.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
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
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 3,
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: grey5,
                    child: Text(
                        sanitizeContactName(widget._contact.displayName)
                            .substring(0, 2)
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 10),
                    child: Text(
                      widget._contact.displayName.isNotEmpty
                          ? sanitizeContactName(widget._contact.displayName)
                          : widget._contact.contactId.id,
                      style: TextStyle(color: white),
                    ),
                  ),
                ],
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const CustomAssetImage(path: ImagePaths.speaker_icon),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const CustomAssetImage(path: ImagePaths.mute_icon),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const CustomAssetImage(path: ImagePaths.hangup_icon),
                    onPressed: () {
                      widget._model.signaling.bye(session);
                      Navigator.of(context).pop();
                    },
                  )
                ]),
          ],
        ),
      ),
    );
  }
}

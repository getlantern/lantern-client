import 'package:flutter/services.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class CopiedTextWidget extends StatefulWidget {
  final PathAndValue<StoredMessage> _message;

  CopiedTextWidget(this._message);

  @override
  State<StatefulWidget> createState() {
    return CopiedTextWidgetState();
  }
}

class CopiedTextWidgetState extends State<CopiedTextWidget> {
  var _copied = false;

  void _onPointerDown(_) {
    setState(() {
      _copied = true;
    });
    Clipboard.setData(ClipboardData(text: widget._message.value.text));
  }

  void _onPointerUp(_) async {
    await Future.delayed(
        const Duration(milliseconds: 600), () => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerUp: _onPointerUp,
        onPointerDown: _onPointerDown,
        child: ListTile(
          leading: _copied
              ? const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
              : const Icon(Icons.copy),
          title: Text('Copy Text'.i18n),
        ));
  }
}

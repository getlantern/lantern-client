import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';

class ReplySnippetText extends StatelessWidget {
  const ReplySnippetText({
    Key? key,
    required this.quotedMessage,
  }) : super(key: key);

  final StoredMessage? quotedMessage;

  @override
  Widget build(BuildContext context) {
    return Flexible(
        fit: FlexFit.tight,
        child: Text(quotedMessage!.text, overflow: TextOverflow.ellipsis));
  }
}

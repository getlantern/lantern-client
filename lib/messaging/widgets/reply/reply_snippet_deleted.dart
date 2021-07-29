import 'package:lantern/package_store.dart';

class ReplySnippetDeleted extends StatelessWidget {
  const ReplySnippetDeleted({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Message deleted'.i18n, style: tsReplySnippetSpecialCase);
  }
}

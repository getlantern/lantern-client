import 'package:lantern/messaging/messaging.dart';

class ReplySnippetDescription extends StatelessWidget {
  const ReplySnippetDescription({
    Key? key,
    required this.descriptiveText,
  }) : super(key: key);

  final String descriptiveText;

  @override
  Widget build(BuildContext context) {
    return CText(
      descriptiveText,
      style: tsBody3.copiedWith(fontStyle: FontStyle.italic),
      overflow: TextOverflow.ellipsis,
    );
  }
}

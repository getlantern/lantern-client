import 'package:lantern/package_store.dart';

class ReplySnippetDescription extends StatelessWidget {
  const ReplySnippetDescription({
    Key? key,
    required this.descriptiveText,
  }) : super(key: key);

  final String descriptiveText;

  @override
  Widget build(BuildContext context) {
    return Text(
      descriptiveText,
      style: tsReplySnippetSpecialCase,
      overflow: TextOverflow.ellipsis,
    );
  }
}

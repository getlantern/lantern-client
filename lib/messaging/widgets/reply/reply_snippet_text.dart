import 'package:lantern/package_store.dart';

class ReplySnippetText extends StatelessWidget {
  const ReplySnippetText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, overflow: TextOverflow.ellipsis);
  }
}

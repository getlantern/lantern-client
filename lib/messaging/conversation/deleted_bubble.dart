import 'package:lantern/messaging/messaging.dart';

class DeletedBubble extends StatelessWidget {
  final String deletedBubbleContent;

  const DeletedBubble(this.deletedBubbleContent) : super();

  @override
  Widget build(BuildContext context) {
    // more at https://pub.dev/packages/dotted_border
    return DottedBorder(
      color: Colors.black38,
      radius: const Radius.circular(8),
      dashPattern: [3],
      strokeWidth: 1,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: CText(deletedBubbleContent, style: tsReplySnippetSpecialCase),
        ),
      ),
    );
  }
}

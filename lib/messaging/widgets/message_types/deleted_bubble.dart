import 'package:lantern/package_store.dart';
import 'package:dotted_border/dotted_border.dart';

class DeletedBubble extends StatelessWidget {
  const DeletedBubble({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // more at https://pub.dev/packages/dotted_border
    return DottedBorder(
      color: Colors.black38,
      radius: const Radius.circular(50),
      dashPattern: [6],
      strokeWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
          child: Text('This message was deleted'), // TODO: Add i18n
        ),
      ),
    );
  }
}

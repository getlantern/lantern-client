import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class ContactIntroPreview extends StatelessWidget {
  final PathAndValue<Contact> contact;
  final int index;
  final Widget leading;
  final Widget trailing;

  ContactIntroPreview(this.contact, this.index, this.leading, this.trailing)
      : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return model.contact(context, contact,
        (BuildContext context, Contact contact, Widget? child) {
      var topBorderWidth = index.isEven ? 0.5 : 0.0;
      var bottomBorderWidth = index.isOdd ? 0.0 : 0.5;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(width: topBorderWidth, color: Colors.black12),
          bottom: BorderSide(width: bottomBorderWidth, color: Colors.black12),
        )),
        child: ListTile(
          leading: leading,
          title: Text(
            sanitizeContactName(contact),
          ),
          trailing: trailing,
        ),
      );
    });
  }
}

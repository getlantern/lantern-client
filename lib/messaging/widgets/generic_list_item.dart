import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

/*
* Generic widget that renders a row with an avatar, a name and a trailing widget. 
* Used in displaying lists of messages, contacts and contact requests.
*/
class GenericListItem extends StatelessWidget {
  GenericListItem({
    Key? key,
    required this.contact,
    required this.index,
    this.isContactPreview,
    required this.title,
    this.subtitle,
    required this.leading,
    required this.trailing,
    this.onTap,
  }) : super();

  final PathAndValue<Contact> contact;
  final int index;
  final bool? isContactPreview;
  final String title;
  final Widget? subtitle;
  final Widget leading;
  final Widget trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return model.contact(context, contact,
        (BuildContext context, Contact contact, Widget? child) {
      // TODO this needs a slight tweaking since we are grouping elements now
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
          title: Text(title.toString()),
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        ),
      );
    });
  }
}

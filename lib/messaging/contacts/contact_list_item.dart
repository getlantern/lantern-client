import 'package:lantern/messaging/messaging.dart';

/*
* Generic widget that renders a row with a Contact avatar, a Contact name and a trailing widget. 
* Used in displaying lists of messages, contacts and contact requests.
*/
class ContactListItem extends StatelessWidget {
  ContactListItem({
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

  final Contact contact;
  final int index;
  final bool? isContactPreview;
  final String title;
  final Widget? subtitle;
  final Widget leading;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
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
  }
}

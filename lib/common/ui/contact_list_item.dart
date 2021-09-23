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
    this.disableBorders = false,
  }) : super();

  final Contact contact;
  final int index;
  final bool? isContactPreview;
  final Widget title;
  final Widget? subtitle;
  final Widget leading;
  final Widget? trailing;
  final void Function()? onTap;
  final bool disableBorders;

  @override
  Widget build(BuildContext context) => Wrap(
        children: [
          CListTile(
              leading: leading,
              content: Wrap(
                direction: Axis.vertical,
                children: [
                  title,
                  subtitle ?? const SizedBox(),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8.0),
                child: trailing ?? const SizedBox(),
              ),
              onTap: onTap),
        ],
      );
}

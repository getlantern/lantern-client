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
    this.subTitle,
    required this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  }) : super();

  final Contact contact;
  final int index;
  final bool? isContactPreview;
  final String title;
  final String? subTitle;
  final Widget leading;
  final Widget? trailing;
  final void Function()? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Wrap(
        children: [
          CListTile(
              leading: leading,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !title.contains('*')
                      ? CText(title.toString(),
                          maxLines: 1, style: tsSubtitle1Short)
                      : TextHighlighter(text: title, style: tsSubtitle1),
                  if (subTitle != null)
                    !subTitle!.contains('*')
                        ? CText(subTitle!,
                            maxLines: 1,
                            style: tsBody2.copiedWith(color: grey5))
                        : TextHighlighter(text: subTitle!, style: tsBody2),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8.0),
                child: trailing ?? const SizedBox(),
              ),
              onTap: onTap,
              showDivider: showDivider),
        ],
      );
}

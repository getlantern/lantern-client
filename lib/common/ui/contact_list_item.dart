import 'package:lantern/messaging/messaging.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
    this.useMarkdown = false,
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
  final bool useMarkdown;

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
                  !useMarkdown
                      ? CText(title.toString(),
                          maxLines: 1, style: tsSubtitle1Short)
                      : MarkdownBody(
                          data: title,
                          styleSheet: MarkdownStyleSheet(
                            p: tsSubtitle1Short,
                            strong: tsSubtitle1Short.copiedWith(
                                color: pink4, fontWeight: FontWeight.w500),
                          ),
                        ),
                  if (subTitle != null)
                    !useMarkdown
                        ? CText(subTitle!,
                            maxLines: 1,
                            style: tsBody2.copiedWith(color: grey5))
                        : MarkdownBody(
                            data: subTitle!,
                            styleSheet: MarkdownStyleSheet(
                              p: tsBody2,
                              a: tsBody2.copiedWith(
                                  decoration: TextDecoration.underline),
                              em: tsBody2.copiedWith(
                                  color: pink4, fontWeight: FontWeight.w500),
                              strong: tsBody2.copiedWith(
                                  color: pink4, fontWeight: FontWeight.w500),
                            ),
                          ),
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

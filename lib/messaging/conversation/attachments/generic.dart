import 'package:lantern/messaging/messaging.dart';

class GenericAttachment extends StatelessWidget {
  const GenericAttachment({
    Key? key,
    required this.attachmentTitle,
    required this.fileExtension,
    required this.inbound,
  }) : super(key: key);

  final String? attachmentTitle;
  final String? fileExtension;
  final bool inbound;

  @override
  Widget build(BuildContext context) {
    final title = attachmentTitle ?? '';
    final fileType = fileExtension ?? '';
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: CAssetImage(
              path: ImagePaths.insert_drive_file,
              color: inbound ? black : white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150.0,
                child: CText(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  // TODO: move this into text_styles.dart
                  style: CTextStyle(
                    color: inbound ? inboundMsgColor : outboundMsgColor,
                    fontSize: 12,
                    lineHeight: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Divider(height: 2.0),
              CText(fileType.toUpperCase(),
                  style: CTextStyle(
                    color: inbound ? inboundMsgColor : outboundMsgColor,
                    fontSize: 12,
                    lineHeight: 16,
                    fontWeight: FontWeight.w500,
                  ))
            ],
          )
        ],
      ),
    );
  }
}

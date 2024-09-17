import 'package:lantern/features/messaging/messaging.dart';

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
    final extension = fileExtension != null ? '.$fileExtension' : '';
    final title = attachmentTitle != null
        ? '$attachmentTitle$extension'
        : 'could_not_render_title'.i18n;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        top: 16,
        bottom: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: CAssetImage(
              path: ImagePaths.insert_drive_file,
              color: inbound ? black : white,
            ),
          ),
          Flexible(
            child: CText(
              title,
              style: tsBody3.copiedWith(
                color: inbound ? inboundMsgColor : outboundMsgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

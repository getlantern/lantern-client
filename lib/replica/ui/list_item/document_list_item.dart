import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

class ReplicaDocumentListItem extends StatelessWidget {
  ReplicaDocumentListItem({
    required this.item,
    required this.onTap,
    required this.replicaApi,
    Key? key,
  }) : super(key: key);

  final ReplicaSearchItem item;
  final Function() onTap;
  final ReplicaApi replicaApi;

  @override
  Widget build(BuildContext context) {
    return ListItemFactory.replicaItem(
      link: item.replicaLink,
      api: replicaApi,
      leading: renderMimeIcon(item.fileNameTitle, 1.0),
      onTap: onTap,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CText(
              removeExtension(item.fileNameTitle),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: tsSubtitle1Short.copiedWith(color: grey5),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8.0),
            child: CText(item.humanizedFileSize, style: tsBody1),
          ),
          // renderMimeType()
        ],
      ),
    );
  }

  // Render the duration and mime types
  // If mimetype is nil, just render 'document/unknown'
  Widget renderMimeType() => Row(
        children: [
          if (item.primaryMimeType != null)
            CText(
              item.primaryMimeType!,
              style: tsBody1.copiedWith(color: pink4),
            )
          else
            CText(
              'document_unknown'.i18n,
              style: tsBody1.copiedWith(color: pink4),
            ),
        ],
      );
}

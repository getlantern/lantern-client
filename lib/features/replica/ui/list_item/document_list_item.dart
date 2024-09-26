import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:lantern/features/vpn/vpn.dart';

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
    final hasDescription = item.metaDescription != '';
    return ListItemFactory.replicaItem(
      link: item.replicaLink,
      api: replicaApi,
      leading: renderMimeIcon(item.fileNameTitle, 1.0),
      onTap: onTap,
      content: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: hasDescription ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                renderFilename(),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: CText(item.humanizedFileSize, style: tsBody1),
                ),
              ],
            ),
            if (hasDescription) Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                renderDescription(),
                // Padding(
                //   padding: EdgeInsetsDirectional.only(start: 8.0),
                //   child: renderMimeType(), // Figma has no mimeType, but maybe useful to end user?
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget renderFilename() {
    return Expanded(
      child: CText(
        removeExtension(item.fileNameTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tsSubtitle1Short.copiedWith(color: grey5),
      ),
    );
  }

  // If mimetype is nil, just render 'document/unknown'
  Widget renderMimeType() => CText(
    item.primaryMimeType != null ? item.primaryMimeType! : 'document_unknown'.i18n,
    style: tsBody2Short.copiedWith(color: grey5),
  );

  Widget renderDescription() {
    return Expanded(
      child:
      CText(
        item.metaDescription,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tsBody2Short,
      ),
    );
  }
}

import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

// @echo
class ReplicaAppListItem extends StatelessWidget {
  ReplicaAppListItem({
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
      leading: renderMimeIcon(item.displayName, 1.0),
      onTap: onTap,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: [
          CText(
            removeExtension(item.displayName),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: tsSubtitle1Short,
          ),
          // Render the duration and mime types
          // If mimetype is nil, just render 'app/unknown'
          Row(
            children: [
              CText(item.humanizedFileSize, style: tsBody1),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
              if (item.primaryMimeType != null)
                CText(
                  item.primaryMimeType!,
                  style: tsBody1.copiedWith(color: pink4),
                )
              else
                CText(
                  'app_unknown'.i18n,
                  style: tsBody1.copiedWith(color: pink4),
                ),
            ],
          )
        ],
      ),
    );
  }
}

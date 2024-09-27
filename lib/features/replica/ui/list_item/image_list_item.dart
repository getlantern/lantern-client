import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';

// @echo
class ReplicaImageListItem extends StatelessWidget {
  ReplicaImageListItem({
    required this.item,
    required this.onTap,
    required this.replicaApi,
    Key? key,
  }) : super(key: key);
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FocusedMenuHolder(
        menu: renderReplicaLongPressMenuItem(
          context,
          replicaApi,
          item.replicaLink,
        ),
        menuWidth: MediaQuery.of(context).size.width * 0.5,
        builder: (_) {
          return GridTile(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                renderImageThumbnail(
                  imageUrl: replicaApi.getThumbnailAddr(item.replicaLink),
                  item: item,
                ),
                renderName(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget renderName(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 8.0,
              end: 8.0,
              top: 4.0,
            ),
            child: CText(
              removeExtension(item.fileNameTitle),
              maxLines: 1,
              style: tsBody2Short,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    );
  }
}

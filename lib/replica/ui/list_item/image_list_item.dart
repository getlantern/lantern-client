import 'package:flutter/material.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/focused_menu.dart';
import 'package:lantern/common/ui/text_styles.dart';
import 'package:lantern/replica/common.dart';

// TODO <08-08-22, kalli> Update to reflect Figma
// @echo
class ReplicaImageListItem extends StatelessWidget {
  ReplicaImageListItem({
    required this.item,
    required this.onTap,
    required this.replicaApi,
  });
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      child: GestureDetector(
        onTap: onTap,
        child: FocusedMenuHolder(
          menu: renderReplicaLongPressMenuItem(
              context, replicaApi, item.replicaLink),
          menuWidth: MediaQuery.of(context).size.width * 0.8,
          builder: (_) {
            return GridTile(
              child: Column(
                children: [
                  renderImageThumbnail(
                    imageUrl: replicaApi.getThumbnailAddr(item.replicaLink),
                    item: item,
                    size: 100,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                  renderName(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget renderName() {
    return CText(
      removeExtension(item.displayName),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: tsBody2Short,
    );
  }
}

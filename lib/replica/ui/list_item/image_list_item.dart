import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/focused_menu.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/common/ui/text_styles.dart';
import 'package:lantern/replica/common.dart';

// TODO <08-08-22, kalli> Update to reflect Figma
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
                  renderThumbnail(),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
                  renderDescription(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget renderDescription() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: CText(
        item.displayName,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: tsBody2,
      ),
    );
  }

  Widget renderThumbnail() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: CachedNetworkImage(
            imageUrl: replicaApi.getThumbnailAddr(item.replicaLink),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Stack(
              children: [
                Container(color: grey4),
                const Center(
                  child: CAssetImage(
                    path: ImagePaths.image_inactive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

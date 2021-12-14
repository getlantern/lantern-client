import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lantern/common/ui/focused_menu.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

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
        child: GestureDetector(
      onTap: onTap,
      child: FocusedMenuHolder(
        menu: renderReplicaLongPressMenuItem(replicaApi, item.replicaLink),
        menuWidth: MediaQuery.of(context).size.width * 0.8,
        builder: (_) {
          return GridTile(
              child: Column(
            children: [
              renderThumbnail(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
              renderDescription(),
            ],
          ));
        },
      ),
    ));
  }

  Widget renderDescription() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        item.displayName,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12.0,
        ),
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
              errorWidget: (context, url, error) =>
                  Container(color: Colors.black)),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listitems/common_listitem.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaImageListItem extends ReplicaCommonListItem {
  ReplicaImageListItem({
    required this.item,
    required Function() onDownloadBtnPressed,
    required Function() onShareBtnPressed,
    required Function() onTap,
    required this.replicaApi,
  }) : super(
          onDownloadBtnPressed: onDownloadBtnPressed,
          onShareBtnPressed: onShareBtnPressed,
          onTap: onTap,
        );
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;

  @override
  State<StatefulWidget> createState() =>
      _ReplicaImageListItem(replicaApi, item);
}

class _ReplicaImageListItem extends ReplicaCommonListItemState {
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;
  _ReplicaImageListItem(this.replicaApi, this.item);

  @override
  Widget build(BuildContext context) {
    return boilerplate(GridTile(
        child: Column(
      children: [
        renderThumbnail(),
        const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
        renderDescription(),
      ],
    )));
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
          fontSize: 9.0,
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/image_item.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaImageListTile extends StatelessWidget {
  const ReplicaImageListTile({
    required this.imageItem,
    required this.onDownloadBtnPressed,
    required this.onShareBtnPressed,
    required this.replicaApi,
  });

  final ReplicaImageItem imageItem;
  final Function() onDownloadBtnPressed;
  final Function() onShareBtnPressed;
  final ReplicaApi replicaApi;

  @override
  Widget build(BuildContext context) {
    // TODO Since the images **always** take 2-3 seconds to load, maybe just
    // **don't** render the list immediately, but fetch the metadata first and
    // then show them after a 2-3 seconds delay, just like YouTube does it.
    return Card(
        child: PopupMenuButton(
      child: InkWell(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CachedNetworkImage(
                        imageUrl:
                            replicaApi.getThumbnailAddr(imageItem.replicaLink!),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            // XXX <02-12-2021> soltzen: render nothing if the
                            // thumbnail request failed.
                            const SizedBox.shrink()),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                    Text(
                      imageItem.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ))),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'download',
          child: const Text('Download'),
          onTap: () => onDownloadBtnPressed(),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: const Text('Share'),
          onTap: () => onShareBtnPressed(),
        ),
      ],
    ));
  }
}

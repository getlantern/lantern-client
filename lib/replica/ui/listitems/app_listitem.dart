import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/i18n/i18n.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listitems/common_listitem.dart';

class ReplicaAppListItem extends ReplicaCommonListItem {
  ReplicaAppListItem({
    required this.item,
    required Function() onDownloadBtnPressed,
    required Function() onShareBtnPressed,
    required Function() onTap,
  }) : super(
          onDownloadBtnPressed: onDownloadBtnPressed,
          onShareBtnPressed: onShareBtnPressed,
          onTap: onTap,
        );

  final ReplicaSearchItem item;

  @override
  State<StatefulWidget> createState() => _ReplicaAppListItemState(item);
}

class _ReplicaAppListItemState extends ReplicaCommonListItemState {
  final ReplicaSearchItem item;
  _ReplicaAppListItemState(this.item);

  @override
  Widget build(BuildContext context) {
    return boilerplate(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            // Render the document icon
            // TODO Pick the icon based on the mimetype
            const CAssetImage(path: ImagePaths.doc),
            // Render some space
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
            // Render the text. It should look like
            //
            //    DISPLAY_NAME
            //    FILESIZE document/MIMETYPE
            //
            //    where DISPLAY_NAME is the display name of the file,
            //      taken directly from the 'dn' query parameter of a
            //      replica link.
            //    and DURATION is 'hh:mm:ss'
            //    and MIMETYPE is PDF, txt, etc.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.all(4.0),
                    child: Text(
                      item.displayName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                  // Render the duration and mime types
                  // If mimetype is nil, just render 'document/unknown'
                  Row(
                    children: [
                      Text(
                        item.humanizedFileSize,
                        style: TextStyle(fontSize: 8.0, color: black),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0)),
                      if (item.primaryMimeType != null)
                        Text(
                          item.primaryMimeType!,
                          style: TextStyle(fontSize: 8.0, color: indicatorRed),
                        )
                      else
                        Text(
                          'document/unknown'.i18n,
                          style: TextStyle(fontSize: 8.0, color: indicatorRed),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        )));
  }
}

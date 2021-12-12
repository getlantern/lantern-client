import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/i18n/i18n.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listitems/common_listitem.dart';

class ReplicaAudioListItem extends ReplicaCommonListItem {
  ReplicaAudioListItem({
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
      _ReplicaAudioListItem(replicaApi, item);
}

class _ReplicaAudioListItem extends ReplicaCommonListItemState {
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;
  late Future<double> _fetchDurationFuture;
  _ReplicaAudioListItem(this.replicaApi, this.item);

  @override
  void initState() {
    _fetchDurationFuture = replicaApi.fetchDuration(item.replicaLink);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return boilerplate(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            // Render the audio icon
            const CAssetImage(path: ImagePaths.audio),
            // Render some space
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
            // Render the text. It should look like
            //
            //    DISPLAY_NAME
            //    DURATION audio/MIMETYPE
            //
            //    where DISPLAY_NAME is the display name of the file,
            //      taken directly from the 'dn' query parameter of a
            //      replica link.
            //    and DURATION is 'hh:mm:ss'
            //    and MIMETYPE is mp3, flac, 3gp, etc.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Render audio file name
                  renderAudioFilename(),
                  renderDurationAndMimetype()
                ],
              ),
            ),
          ],
        )));
  }

  Widget renderAudioFilename() {
    return Padding(
      padding: const EdgeInsetsDirectional.all(4.0),
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

  // Render the duration and mime types
  // If mimetype is nil, just render 'audio/unknown'
  Widget renderDurationAndMimetype() {
    return Row(
      children: [
        FutureBuilder(
          future: _fetchDurationFuture,
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text(
                '??:??',
                style: TextStyle(fontSize: 8.0),
              );
            }
            return Text(
              snapshot.data!.toStringAsFixed(2),
              style: const TextStyle(fontSize: 8.0),
            );
          },
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
        if (item.primaryMimeType != null)
          Text(
            item.primaryMimeType!,
            style: TextStyle(fontSize: 8.0, color: indicatorRed),
          )
        else
          Text(
            'audio/unknown'.i18n,
            style: TextStyle(fontSize: 8.0, color: indicatorRed),
          ),
      ],
    );
  }
}

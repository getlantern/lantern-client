import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/search_item.dart';

class ReplicaAudioListItem extends StatefulWidget {
  ReplicaAudioListItem(
      {required this.item, required this.onTap, required this.replicaApi});

  final ReplicaSearchItem item;
  final Function() onTap;
  final ReplicaApi replicaApi;

  @override
  State<StatefulWidget> createState() => _ReplicaAudioListItem();
}

class _ReplicaAudioListItem extends State<ReplicaAudioListItem> {
  late Future<double?> _fetchDurationFuture;

  @override
  void initState() {
    _fetchDurationFuture =
        widget.replicaApi.fetchDuration(widget.item.replicaLink);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListItemFactory.replicaItem(
        link: widget.item.replicaLink,
        api: widget.replicaApi,
        leading: const CAssetImage(path: ImagePaths.audio),
        onTap: widget.onTap,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [
            // Render audio file name
            renderAudioFilename(),
            renderDurationAndMimetype()
          ],
        ));
  }

  Widget renderAudioFilename() {
    return CText(
      widget.item.displayName,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: tsSubtitle1Short,
    );
  }

  // Render the duration and mime types
  // If mimetype is nil, just render 'audio/unknown'
  Widget renderDurationAndMimetype() {
    return Row(
      children: [
        FutureBuilder(
          future: _fetchDurationFuture,
          builder: (BuildContext context, AsyncSnapshot<double?> snapshot) {
            // if we got an error,
            // or, didn't receive data,
            // or, got null data,
            // display ??:??
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return Container();
            }
            return CText(
              snapshot.data!.toMinutesAndSeconds(),
              style: tsBody1,
            );
          },
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
        if (widget.item.primaryMimeType != null)
          CText(
            widget.item.primaryMimeType!,
            style: tsBody1.copiedWith(color: pink4),
          )
        else
          CText(
            'audio/unknown'.i18n,
            style: tsBody1.copiedWith(color: pink4),
          ),
      ],
    );
  }
}

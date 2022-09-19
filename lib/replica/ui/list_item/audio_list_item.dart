import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

class ReplicaAudioListItem extends StatelessWidget {
  ReplicaAudioListItem({
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
      leading: renderPlayIcon(item.replicaLink),
      onTap: onTap,
      content: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                renderAudioFilename(),
                renderDuration(),
              ],
            ),
            renderMimeType(),
          ],
        ),
      ),
    );
  }

  Widget renderAudioFilename() {
    return Expanded(
      child: CText(
        removeExtension(item.fileNameTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tsSubtitle1Short.copiedWith(color: grey5),
      ),
    );
  }

  Widget renderDuration() {
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: replicaApi.getDuration(item.replicaLink),
          builder: (
            BuildContext context,
            CachedValue<double?> cached,
            Widget? child,
          ) =>
              CText(
            cached.value != null ? cached.value!.toMinutesAndSeconds() : '',
            style: tsBody1.copiedWith(color: grey5),
          ),
        ),
      ],
    );
  }

  // If mimetype is nil, just render 'audio/unknown'
  Widget renderMimeType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (item.primaryMimeType != null)
          CText(
            item.primaryMimeType!,
            style: tsBody1.copiedWith(color: grey5),
          )
        else
          CText(
            'audio_unknown'.i18n,
            style: tsBody1.copiedWith(color: grey5),
          ),
      ],
    );
  }
}

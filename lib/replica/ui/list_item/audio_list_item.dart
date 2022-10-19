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
    final hasDescription = item.metaDescription != '';
    return ListItemFactory.replicaItem(
      link: item.replicaLink,
      api: replicaApi,
      leading: renderPlayIcon(item.replicaLink),
      onTap: onTap,
      content: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: hasDescription
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                renderAudioFilename(),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: renderDuration(),
                ),
              ],
            ),
            if (hasDescription)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  renderDescription(),
                  // Padding(
                  //   padding: const EdgeInsetsDirectional.only(start: 8.0),
                  //   child: renderMimeType(), // Figma has no mimeType, but maybe useful to end user?
                  // ),
                ],
              ),
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
    return ValueListenableBuilder(
      valueListenable: replicaApi.getDuration(item.replicaLink),
      builder: (
        BuildContext context,
        CachedValue<double?> cached,
        Widget? child,
      ) =>
          CText(
        cached.value != null ? cached.value!.toMinutesAndSeconds() : '',
        style: tsBody1,
      ),
    );
  }

  // If mimetype is nil, just render 'audio/unknown'
  Widget renderMimeType() => CText(
        item.primaryMimeType != null
            ? item.primaryMimeType!
            : 'audio_unknown'.i18n,
        style: tsBody2Short.copiedWith(color: grey5),
      );

  Widget renderDescription() {
    return Expanded(
      child: CText(
        item.metaDescription,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tsBody2Short,
      ),
    );
  }
}

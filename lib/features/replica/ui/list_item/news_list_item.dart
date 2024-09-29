import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';

class ReplicaNewsListItem extends StatelessWidget {
  ReplicaNewsListItem({
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
      serpLink: item.serpLink,
      api: replicaApi,
      onTap: onTap,
      content: SizedBox(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [renderTitle, renderLink, renderSnippet]
              .map((f) => Row(children: [f()]))
              .toList(),
        ),
      ),
    );
  }

  Widget renderTitle() {
    return Expanded(
      child: CText(
        item.serpTitle ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tsSubtitle1Short.copiedWith(color: blue5),
      ),
    );
  }

  Widget renderLink() {
    return Expanded(
      child:
      Padding(
        padding: const EdgeInsetsDirectional.only(top: 4, bottom: 4),
        child: CText(
          item.serpLink ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tsBody2Short.copiedWith(color: grey5),
        ),
      ),
    );
  }

  Widget renderSnippet() {
    return Expanded(
      child:
      CText(
        item.serpSnippet ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tsBody2Short,
      ),
    );
  }
}
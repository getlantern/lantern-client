import 'package:lantern/core/utils/common.dart';

class ListSectionHeader extends StatelessWidget {
  final String text;

  ListSectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(
                start: 6,
                top: 21,
                bottom: 3,
              ),
              child: CText(text.toUpperCase(), maxLines: 1, style: tsOverline),
            ),
          ],
        ),
        const CDivider(),
      ],
    );
  }
}

import 'package:lantern/package_store.dart';

class SectionHeader extends StatelessWidget {
  late final String label;
  late final bool showTopDivider;
  late final EdgeInsets? padding;

  SectionHeader(
      {Key? key,
      required this.label,
      this.showTopDivider = false,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(top: showTopDivider ? 8 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTopDivider)
            CustomDivider(
              padding: const EdgeInsetsDirectional.only(bottom: 16),
            ),
          Text(
            label.toUpperCase() + ':',
            style: const TextStyle(fontSize: 10),
          ),
          CustomDivider(),
        ],
      ),
    );
  }
}

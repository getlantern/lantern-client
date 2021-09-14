import 'package:lantern/account/account.dart';

class SettingsSectionHeader extends StatelessWidget {
  late final String label;
  late final EdgeInsets? padding;

  SettingsSectionHeader({Key? key, required this.label, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(start: 8),
            child: Text(
              label.toUpperCase() + ':',
              style: const TextStyle(fontSize: 10),
            ),
          ),
          CustomDivider(
            height: 1,
            padding: const EdgeInsetsDirectional.only(top: 8),
          ),
        ],
      ),
    );
  }
}

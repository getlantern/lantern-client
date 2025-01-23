import 'package:package_info_plus/package_info_plus.dart';

import '../utils/common.dart';

class VersionFooter extends StatelessWidget {
  const VersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        final packageInfo = snapshot.data;
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CText(
                'version_number'.i18n.fill([packageInfo?.version ?? '']),
                style: tsOverline.copiedWith(color: pink4),
              ),
              const SizedBox(width: 8),
              CText(
                'build_number'.i18n.fill([packageInfo?.buildNumber ?? '']),
                style: tsOverline.copiedWith(color: pink4),
              ),
              const SizedBox(width: 8),
              sessionModel.sdkVersion(
                (context, sdkVersion, _) => Expanded(
                  child: CText(
                    'sdk_version'.i18n.fill([sdkVersion]),
                    overflow: TextOverflow.ellipsis,
                    style: tsOverline.copiedWith(
                      color: pink4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

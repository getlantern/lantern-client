import 'package:lantern/common/common.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const SHARE_LINK = 'https://github.com/getlantern/lantern';

@RoutePage(name: 'LanternDesktop')
class LanternDesktop extends StatelessWidget {
  const LanternDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'lantern_desktop'.i18n,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.only(top: 24, bottom: 32),
            child: CAssetImage(path: ImagePaths.lantern_desktop, size: 136),
          ),
          InkWell(
              child: CText(SHARE_LINK, style: tsBody3.copiedWith(color: blue4)),
              onTap: () => launch(SHARE_LINK)),
          Padding(
            padding:
                const EdgeInsetsDirectional.only(top: 24, start: 12, end: 12),
            child: CText(
              'most_recent_lantern_apps'.i18n,
              textAlign: TextAlign.justify,
              style: tsBody2,
            ),
          ),
          const Spacer(),
          Container(
              margin: const EdgeInsetsDirectional.only(bottom: 56),
              child: Button(
                width: 200,
                text: 'share_link'.i18n,
                onPressed: () async => await Share.share(SHARE_LINK),
              )),
        ],
      ),
    );
  }
}

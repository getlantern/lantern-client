import 'package:url_launcher/url_launcher.dart';

import '../common/common.dart';

@RoutePage<void>(name: 'Support')
class Support extends StatelessWidget {
  const Support({Key? key}) : super(key: key);

  final faqUrl = 'https://lantern.io/faq';
  final forumsUrl = 'https://lantern.io/forums';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'support'.i18n,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        //* Report
        ListItemFactory.settingsItem(
          icon: ImagePaths.alert,
          key: AppKeys.reportIssue,
          content: 'report_issue'.i18n,
          trailingArray: [
            mirrorLTR(context: context, child: const ContinueArrow())
          ],
          onTap: () {
            reportIssue(context);
          },
        ),
        ListItemFactory.settingsItem(
          content: 'lantern_user_forum'.i18n,
          icon: ImagePaths.forum,
          trailingArray: [
            mirrorLTR(
              context: context,
              child: const Padding(
                padding: EdgeInsetsDirectional.only(start: 4.0),
                child: CAssetImage(
                  path: ImagePaths.open,
                ),
              ),
            )
          ],
          onTap: () => forumTap(context),
        ),
        ListItemFactory.settingsItem(
          content: 'faq'.i18n,
          icon: ImagePaths.info,
          trailingArray: [
            mirrorLTR(
              context: context,
              child: const Padding(
                padding: EdgeInsetsDirectional.only(start: 4.0),
                child: CAssetImage(
                  path: ImagePaths.open,
                ),
              ),
            )
          ],
          onTap: () => faqTap(context),
        ),
      ],
    );
  }

  // class methods and utils

  void reportIssue(BuildContext context) async => context.pushRoute(ReportIssue());

  Future<void> faqTap(BuildContext context) async {
    try {
      await launchUrl(Uri.parse(faqUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      showSnackbar(context: context, content: 'Fail to open link ');
    }
  }

  Future<void> forumTap(BuildContext context) async {
    try {
      await launchUrl(
        Uri.parse(forumsUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      showSnackbar(context: context, content: 'Fail to open link ');
    }
  }
}

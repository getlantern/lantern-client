

import 'package:lantern/core/app/app_webview.dart';

import '../../core/utils/common.dart';

@RoutePage(name: 'Support')
class Support extends StatelessWidget {
  const Support({super.key});

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

        sessionModel.proUser(
          (context, proUser, child) {
            return FutureBuilder<bool>(
              future: AppMethods.showRestorePurchaseButton(proUser),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data as bool) {
                  return ListItemFactory.settingsItem(
                    content: 'restore_purchase'.i18n,
                    icon: ImagePaths.restore,
                    onTap: () => restorePurchaseTap(context),
                  );
                }
                return const SizedBox();
              },
            );
          },
        )
      ],
    );
  }

  // class methods and utils

  void reportIssue(BuildContext context) async =>
      context.pushRoute(ReportIssue());

  void restorePurchaseTap(BuildContext context) async =>
      context.pushRoute(RestorePurchase());

  Future<void> faqTap(BuildContext context) async {
    try {
      await AppBrowser.openWebview(faqUrl);
    } catch (e) {
      showSnackbar(context: context, content: 'Fail to open link ');
    }
  }

  Future<void> forumTap(BuildContext context) async {
    try {
      await AppBrowser.openWebview(forumsUrl);
    } catch (e) {
      showSnackbar(context: context, content: 'Fail to open link ');
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';

import '../../button.dart';

class AuthorizeDeviceForPro extends StatelessWidget {
  AuthorizeDeviceForPro({Key? key}) : super(key: key);

  void openInfoProxyAll(BuildContext context) {
    showInfoDialog(
      context,
      title: 'proxy_all'.i18n,
      des: 'description_proxy_all_dialog'.i18n,
      icon: ImagePaths.key_icon,
    );
  }

  void linkWithPin() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_LINK_PIN);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'authorize_device_for_pro'.i18n,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Authorize with Device Linking Pin'.i18n,
              style: tsTitleItem(),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(top: 8),
              child: Text(
                'Requires physical access to a Lantern Pro Device'.i18n,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Button(
              width: 200,
              text: 'Link with PIN'.i18n,
              onPressed: linkWithPin,
            ),
            const Spacer(),
            Flexible(
              child: CustomDivider(
                label: 'OR'.i18n,
                labelStyle: tsTitleItem(),
              ),
            ),
            const Spacer(),
            Text(
              'Authorize Device via Email'.i18n,
              style: tsTitleItem(),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(top: 8),
              child: Text(
                'Requires access to the email you used to buy Lantern Pro'.i18n,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Button(
              width: 200,
              text: 'Link via Email'.i18n,
              inverted: true,
              onPressed: () {},
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

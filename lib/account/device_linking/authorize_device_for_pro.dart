import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/account/account.dart';

import '../../common/ui/button.dart';

class AuthorizeDeviceForPro extends StatelessWidget {
  AuthorizeDeviceForPro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Authorize Device for Pro'.i18n,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            CText(
              'Authorize with Device Linking Pin'.i18n,
              style: tsTitle,
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(top: 8),
              child: CText(
                'Requires physical access to a Lantern Pro Device'.i18n,
                style: tsBody13,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Button(
              width: 200,
              text: 'Link with PIN'.i18n,
              onPressed: () {
                LanternNavigator.startScreen(LanternNavigator.SCREEN_LINK_PIN);
              },
            ),
            const Spacer(),
            Flexible(
              child: CVerticalDivider(
                label: 'OR'.i18n,
                labelStyle: tsTitle,
                height: 26,
              ),
            ),
            const Spacer(),
            CText(
              'Authorize Device via Email'.i18n,
              style: tsTitle,
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(top: 8),
              child: CText(
                'Requires access to the email you used to buy Lantern Pro'.i18n,
                style: tsBody13,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Button(
              width: 200,
              text: 'Link via Email'.i18n,
              secondary: true,
              onPressed: () async =>
                  await context.pushRoute(AuthorizeDeviceEmail()),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

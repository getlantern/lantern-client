import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/package_store.dart';

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
            Text(
              'Authorize with Device Linking Pin'.i18n,
              style: tsTitleItem,
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
              onPressed: () {
                LanternNavigator.startScreen(LanternNavigator.SCREEN_LINK_PIN);
              },
            ),
            const Spacer(),
            Flexible(
              child: CustomDivider(
                label: 'OR'.i18n,
                labelStyle: tsTitleItem,
              ),
            ),
            const Spacer(),
            Text(
              'Authorize Device via Email'.i18n,
              style: tsTitleItem,
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

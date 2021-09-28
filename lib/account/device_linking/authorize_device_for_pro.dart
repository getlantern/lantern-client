import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/core/router/router.gr.dart';

import '../../common/ui/button.dart';

class AuthorizeDeviceForPro extends StatelessWidget {
  AuthorizeDeviceForPro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'authorize_device_pro'.i18n,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          CText(
            'authorize_device_pin'.i18n,
            style: tsSubtitle1,
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(top: 8),
            child: CText(
              'requires_physical_access'.i18n,
              style: tsBody2,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Button(
            width: 200,
            text: 'link_with_pin'.i18n,
            onPressed: () {
              LanternNavigator.startScreen(LanternNavigator.SCREEN_LINK_PIN);
            },
          ),
          const Spacer(),
          Flexible(
            child: LabeledDivider(
              label: 'OR'.i18n,
              labelStyle: tsBody3,
              height: 26,
            ),
          ),
          const Spacer(),
          CText(
            'authorize_via_email'.i18n,
            style: tsSubtitle1Short,
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(top: 8),
            child: CText(
              'requires_access_to_email'.i18n,
              style: tsBody2,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Button(
            width: 200,
            text: 'link_via_email'.i18n,
            secondary: true,
            onPressed: () async =>
                await context.pushRoute(AuthorizeDeviceEmail()),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

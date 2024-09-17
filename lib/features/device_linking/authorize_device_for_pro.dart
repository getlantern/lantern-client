import 'package:lantern/core/utils/common.dart';

@RoutePage(name: 'AuthorizePro')
class AuthorizeDeviceForPro extends StatelessWidget {
  const AuthorizeDeviceForPro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Authorize Device for Pro'.i18n,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          CText(
            'Authorize with Device Linking Pin'.i18n,
            style: tsSubtitle1,
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(top: 8),
            child: CText(
              'Requires physical access to a Lantern Pro Device'.i18n,
              style: tsBody2,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Button(
            width: 200,
            text: 'Link with PIN'.i18n,
            onPressed: () => openLinkDevice(context),
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
            'Authorize Device via Email'.i18n,
            style: tsSubtitle1Short,
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(top: 8),
            child: CText(
              'Requires access to the email you used to buy Lantern Pro'.i18n,
              style: tsBody2,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Button(
            text: 'Link via Email'.i18n,
            secondary: true,
            onPressed: () => openLinkDeviceViaEmail(context),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void openLinkDevice(BuildContext context) {
    context.pushRoute(LinkDevice());
  }

  void openLinkDeviceViaEmail(BuildContext context) {
    context.pushRoute(AuthorizeDeviceEmail());
  }
}

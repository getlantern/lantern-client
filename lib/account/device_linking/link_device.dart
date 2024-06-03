import 'package:lantern/common/common.dart';
import 'package:retry/retry.dart';

import 'explanation_step.dart';

@RoutePage<void>(name: 'LinkDevice')
class LinkDevice extends StatefulWidget {
  const LinkDevice({
    Key? key,
  }) : super(key: key);

  @override
  State<LinkDevice> createState() => _LinkDeviceState();
}

class _LinkDeviceState extends State<LinkDevice> {
  @override
  void initState() {
    super.initState();
    if (isMobile()) {
      requestLinkCode();
    }
  }

  Future<void> requestLinkCode() async {
    try {
      await sessionModel.requestLinkCode();
      // We need to call redeemLinkCode multiple times when user enter code we redeem it
      // then it will show on the device list
      retry(
        () => {sessionModel.redeemLinkCode()},
      );
    } catch (e) {
      appLogger.e("error while requesting link code: $e", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Authorize Device for Pro'.i18n,
      body: sessionModel.deviceLinkingCode((BuildContext context,
              String deviceCode, Widget? child) =>
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsetsDirectional.only(top: 24),
                  child: CText(
                    'device_linking_pin'.i18n,
                    textAlign: TextAlign.center,
                    style: tsSubtitle1,
                  )),
              Text(
                deviceCode,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  color: pink4,
                ),
              ),
              LabeledDivider(
                padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 16),
                child: ExplanationStep(
                    ImagePaths.number_1, 'link_device_step_one'.i18n),
              ),
              ExplanationStep(ImagePaths.number_2, 'link_device_step_two'.i18n),
              const Flexible(
                child: CDivider(
                  height: 26,
                ),
              ),
              CText(
                'ensure_most_recent_version_lantern'.i18n,
                textAlign: TextAlign.justify,
                style: tsBody2,
              ),
            ],
          )),
    );
  }
}

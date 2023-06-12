import 'package:lantern/common/common.dart';
import 'explanation_step.dart';

class LinkDevice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    sessionModel.requestLinkCode();
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
              Flexible(
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

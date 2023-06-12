import 'package:lantern/common/common.dart';
import 'explanation_step.dart';

class LinkDevice extends StatelessWidget {
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
          LabeledDivider(
            padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 16),
            child: ExplanationStep(
                ImagePaths.number_1, 'link_device_step_one'.i18n),
          ),
          ExplanationStep(ImagePaths.number_2, 'link_device_step_two'.i18n),
          const Spacer(),
          Flexible(
            child: CDivider(
              height: 26,
            ),
          ),
          CText(
            'ensure_most_recent_version_lantern'.i18n,
            style: tsSubtitle1,
          ),
        ],
      ),
    );
  }
}

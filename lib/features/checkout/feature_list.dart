

import '../../core/utils/common.dart';

class FeatureList extends StatelessWidget {
  FeatureList({super.key});

  final featuresList = [
    'unlimited_data'.i18n,
    'faster_data_centers'.i18n,
    'no_logs'.i18n,
    'connect_up_to_3_devices'.i18n,
    'no_ads'.i18n,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
        children: featuresList
            .map(
              (feature) => Container(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const CAssetImage(
                      path: ImagePaths.check_green_large,
                      size: 24,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 4.0,
                        bottom: 4.0,
                      ),
                      child: CText(
                        feature,
                        textAlign: TextAlign.center,
                        style: tsBody1,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList());
  }
}

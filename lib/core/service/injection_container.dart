import 'package:get_it/get_it.dart';
import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/core/utils/common.dart';

import 'ad_service.dart';
import 'package:lantern/core/service/survey_service.dart';
import 'package:lantern/core/utils/common.dart';

final GetIt sl = GetIt.instance;

void initServices() {
  //Inject
  if (isMobile()) {
    sl.registerLazySingleton(() => AppPurchase());
    sl<AppPurchase>().init();
  }
  sl.registerLazySingleton(() => AdsService());

  sl.registerLazySingleton(() => SurveyService());
}

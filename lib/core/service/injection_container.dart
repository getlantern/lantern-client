import 'package:get_it/get_it.dart';
import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/core/service/survey_service.dart';
import 'package:lantern/core/utils/common.dart';

final GetIt sl = GetIt.instance;

void init() {
  //Inject
  if (isMobile()) {
    sl.registerLazySingleton(() => AppPurchase());
    sl<AppPurchase>().init();
  }

  sl.registerLazySingleton(() => SurveyService());
}

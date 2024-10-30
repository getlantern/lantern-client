import 'package:get_it/get_it.dart';
import 'package:lantern/core/service/app_purchase.dart';

final GetIt sl = GetIt.instance;

void init() {
  //Inject
  sl.registerLazySingleton(() => AppPurchase());
}

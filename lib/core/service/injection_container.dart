import 'package:get_it/get_it.dart';
import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/replica/models/replica_model.dart';

final GetIt sl = GetIt.instance;

void initServices() {
  //Inject

  if (isMobile()) {
    sl.registerLazySingleton(() => AppPurchase());
    sl<AppPurchase>().init();
  }
  sl.registerLazySingleton(() => SessionModel());
  sl.registerLazySingleton(() => MessagingModel());
  sl.registerLazySingleton(() => ReplicaModel());
  sl.registerLazySingleton(() => VpnModel());
}

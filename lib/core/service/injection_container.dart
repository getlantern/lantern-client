import 'package:get_it/get_it.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/router/router.dart';
import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/replica/models/replica_model.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';

final GetIt sl = GetIt.instance;

void initServices() {
  //Inject

  if (isMobile()) {
    sl.registerLazySingleton(() => AppPurchase());
    sl<AppPurchase>().init();
  }
  sl.registerLazySingleton(() => AppRouter());
  sl.registerLazySingleton(() => SessionModel());
  sl.registerLazySingleton(() => MessagingModel());
  sl.registerLazySingleton(() => ReplicaModel());
  sl.registerLazySingleton(() => VpnModel());

  /// Notifiers
   sl.registerLazySingleton(() => BottomBarChangeNotifier());
   sl.registerLazySingleton(() => VPNChangeNotifier());
   sl.registerLazySingleton(() => InternetStatusProvider());

}

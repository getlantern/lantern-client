import 'package:dart_ping/dart_ping.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../core/utils/common.dart';

class InternetChecker extends StatelessWidget {
  const InternetChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return vpnModel.vpnStatus(context, (context, vpnStatus, child) {
      return GestureDetector(
        onTap: () {
          CDialog.showInternetUnavailableDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: const Color(0xFFFFF9DB),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: yellow4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(ImagePaths.cloudOff, height: 25),
              const SizedBox(width: 10),
              Expanded(
                child: CText(
                  vpnStatus == VpnStatus.connected.name
                      ? 'domain_fronting_error'.i18n
                      : 'no_internet_connection'.i18n,
                  textAlign: TextAlign.center,
                  style: tsBody1.copiedWith(color: yellow5),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class InternetStatusProvider extends ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription<InternetStatus> _connectionSubscription;
  bool _isDisconnected = false;

  /// Using debounce to avoid flickering when the connection is unstable
  final _debounceDuration = Duration(seconds: Platform.isIOS ? 5 : 2);
  Timer? _debounceTimer;

  final _regionCheckUrls = {
    'RU': const [
      'https://yandex.ru',
      'https://alibaba.com',
      'https://dzen.ru',
      'https://vk.com'
    ],
    'AE': const [
      'https://espncricinfo.com',
      'https://microsoft.com',
      'https://amazon.ae'
    ],
    'IR': const [
      'https://aparat.com',
      'https://digikala.com',
      'https://divar.ir'
    ],
    'CN': const [
      'https://baidu.com',
      'https://microsoft.com',
      'https://alibaba.com'
    ],
    'DEFAULT': const [
      'https://alibaba.com',
      'https://emirates.com',
      'https://microsoft.com'
    ],
  };

  /// With help of https://dnschecker.org/public-dns/
  /// pinged by https://ping.pe
  final _pingAddress = {
    'IR': const ['194.225.152.10', '81.163.3.2', '217.218.155.155', '1.1.1.1'],
    'AE': const ['180.76.76.76', '223.6.6.41', '140.117.167.174'],
    'RU': const ['92.124.144.189', '77.88.8.1', '94.51.83.154'],
    'CN': const ['180.76.76.76', '223.6.6.41', '140.117.167.174'],
    'DEFAULT': const ['180.76.76.76', '223.6.6.41', '140.117.167.174'],
  };

  InternetStatusProvider() {
    // Listen for connection status changes
    _connectionSubscription = InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 4),
      useDefaultOptions: false,
      customCheckOptions: getRegionSpecificCheckOptions(),
    ).onStatusChange.listen((status) async {
      if (status == InternetStatus.connected) {
        _handleConnected();
      } else {
        /// Check from different ping servers
        /// to make sure internet is working or not
        if ((await pingServers())) {
          _handleConnected();
          return;
        }
        _handleDisconnected();
      }
    });
  }

  bool get isConnected => _isConnected;

  ///Another check on top of internet connection checker
  ///to ping some of the popular websites.
  ///Note that I don't think this works on iOS at all.
  Future<bool> pingServers() async {
    appLogger.d('Pinging servers to check internet connection');
    final countryCode = sessionModel.country.value ?? 'DEFAULT';
    final pingAddresses =
        (_pingAddress[countryCode] ?? _pingAddress['DEFAULT'])!;
    for (String address in pingAddresses) {
      try {
        final ping = Ping(address, count: 3);
        final pinData = await ping.stream.first;
        if (pinData.error != null) {
          appLogger.d('Server ping not found');
          ping.stop();
          continue;
        }
        if (pinData.response != null) {
          appLogger.d('Server ping found');
          ping.stop();
          return true;
        }
      } catch (e) {
        appLogger.d('Server ping failed');
        continue;
      }
    }

    return false;
  }

  Future<void> checkInternetConnection() async {
    // Check the internet connection status
    _isConnected = await InternetConnection().hasInternetAccess;
    // Notify listeners of the change
    notifyListeners();
  }

  void _handleConnected() {
    _cancelDebounceTimer();
    _isDisconnected = false;
    _isConnected = true;
    notifyListeners();
  }

  void _handleDisconnected() {
    _isDisconnected = true;
    _startDebounceTimer();
  }

  void _startDebounceTimer() {
    _cancelDebounceTimer();
    _debounceTimer = Timer(_debounceDuration, () {
      if (_isDisconnected) {
        _isConnected = false;
        notifyListeners();
      }
    });
  }

  void _cancelDebounceTimer() {
    _debounceTimer?.cancel();
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _cancelDebounceTimer();
    super.dispose();
  }

  List<InternetCheckOption> getRegionSpecificCheckOptions() {
    final countryCode = sessionModel.country.value ?? 'DEFAULT';
    final urls =
        (_regionCheckUrls[countryCode] ?? _regionCheckUrls['DEFAULT'])!;
    return urls
        .map((url) => InternetCheckOption(
              uri: Uri.parse(url),
              timeout: const Duration(seconds: 5),
            ))
        .toList();
  }
}

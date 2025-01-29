import 'package:dart_ping/dart_ping.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../core/utils/common.dart';

class InternetChecker extends StatelessWidget {
  const InternetChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CDialog.showInternetUnavailableDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 8),
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
            CText(
              "No internet connection detected",
              textAlign: TextAlign.center,
              style: tsBody1.copiedWith(color: yellow5),
            )
          ],
        ),
      ),
    );
  }
}

class InternetStatusProvider extends ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription<InternetStatus> _connectionSubscription;
  bool _isDisconnected = false;

  /// All website are working in Russia
  /// confirmed by oxylabs proxies

  /// Using debounce to avoid flickering when the connection is unstable
  final _debounceDuration = Duration(seconds: Platform.isIOS ? 4 : 2);
  Timer? _debounceTimer;

  InternetStatusProvider() {
    // Listen for connection status changes
    _connectionSubscription = InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 5),
      useDefaultOptions: false,
      customCheckOptions: getRegionSpecificCheckOptions(),
    ).onStatusChange.listen((status) async {
      if (status == InternetStatus.connected) {
        _handleConnected();
      } else {
        // Check from different ping servers
        // to make sure internet is working or not
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
  ///to ping some of the popular websites
  Future<bool> pingServers() async {
    final List<String> pingAddresses = [
      '8.8.8.8',
      '1.1.1.1',
      '114.114.114.114'
    ]; // Google, Cloudflare, China DNS
    for (String address in pingAddresses) {
      final ping = Ping(address, count: 2);
      final result = await ping.stream.toList();
      if (result.any((res) => res.response != null)) {
        return true;
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
    if (sessionModel.country.value!.isRussia()) {
      return [
        InternetCheckOption(
          uri: Uri.parse('https://yandex.ru'),
          timeout: const Duration(seconds: 5),
        ),
        InternetCheckOption(
          uri: Uri.parse('https://one.one.one.one'),
          timeout: const Duration(seconds: 5),
        ),
      ];
    } else if (sessionModel.country.value!.isChina()) {
      return [
        InternetCheckOption(
          uri: Uri.parse('https://one.one.one.one'),
          timeout: const Duration(seconds: 5),
        ),
        InternetCheckOption(
          uri: Uri.parse('https://baidu.com'), //China
          timeout: const Duration(seconds: 5),
        ),
      ];
    }
    return [
      InternetCheckOption(
        uri: Uri.parse('https://one.one.one.one'),
        timeout: const Duration(seconds: 5),
      ),
      InternetCheckOption(
        uri: Uri.parse('https://google.com'),
        timeout: const Duration(seconds: 5),
      ),
      InternetCheckOption(
        uri: Uri.parse('https://ipapi.co/ip'),
        timeout: const Duration(seconds: 5),
      ),
    ];
  }
}

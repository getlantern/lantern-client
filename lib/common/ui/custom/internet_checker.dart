import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../common.dart';

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
  final List<InternetCheckOption> _defaultCheckOptions = [
    InternetCheckOption(
      uri: Uri.parse('https://icanhazip.com/'),
      timeout: const Duration(seconds: 5),
    ),
    InternetCheckOption(
      uri: Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
      timeout: const Duration(seconds: 5),
    ),
    InternetCheckOption(
      uri: Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1'),
      timeout: const Duration(seconds: 5),
    ),
    InternetCheckOption(
      uri: Uri.parse('https://reqres.in/api/users/1'),
      timeout: const Duration(seconds: 5),
    ),
  ];

  /// Using debounce to avoid flickering when the connection is unstable
  final _debounceDuration = Duration(seconds: Platform.isIOS ? 4 : 2);
  Timer? _debounceTimer;

  InternetStatusProvider() {
    // Listen for connection status changes
    _connectionSubscription = InternetConnection.createInstance(
            checkInterval: const Duration(seconds: 10),
            useDefaultOptions: false,
            customCheckOptions: _defaultCheckOptions)
        .onStatusChange
        .listen((status) {
      if (status == InternetStatus.connected) {
        _handleConnected();
      } else {
        _handleDisconnected();
      }
    });
  }

  bool get isConnected => _isConnected;

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
}

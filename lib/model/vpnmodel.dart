import 'package:flutter/foundation.dart';

class VPNModel extends ChangeNotifier {
  var _vpnOn = false;
  var _serverLocation = "TW";
  var _bandwidthUsed = 300;
  var _dataCap = 500;
  var _isLoading = false;
  DateTime _capResetsAt;

  bool get vpnOn => _vpnOn;

  bool get isLoading => _isLoading;

  String get serverLocation => _serverLocation;

  int get bandwidthUsed => _bandwidthUsed;

  int get dataCap => _dataCap;

  double get dataCapUsedPercentage =>
      _bandwidthUsed.toDouble() / _dataCap.toDouble();

  DateTime get capResetsAt => _capResetsAt;

  void toggle() {
    _isLoading = true;
    notifyListeners();
    Future.delayed(Duration(milliseconds: 1000), () {
      _isLoading = false;
      _vpnOn = !_vpnOn;
      notifyListeners();
    });
  }

  void updateBandwidthUsage(
      int bandwidthUsed, int dataCap, DateTime capResetsAt) {
    _bandwidthUsed = bandwidthUsed;
    _dataCap = dataCap;
    _capResetsAt = capResetsAt;
    notifyListeners();
  }
}

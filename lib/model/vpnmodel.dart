import 'package:flutter/foundation.dart';

class VPNModel extends ChangeNotifier {
  var _vpnOn = false;
  var _serverLocation = "TW";
  var _bandwidthUsed = 300;
  var _dataCap = 500;
  DateTime _capResetsAt;

  bool get vpnOn => _vpnOn;

  String get serverLocation => _serverLocation;

  int get bandwidthUsed => _bandwidthUsed;

  int get dataCap => _dataCap;

  double get dataCapUsedPercentage =>
      _bandwidthUsed.toDouble() / _dataCap.toDouble();

  DateTime get capResetsAt => _capResetsAt;

  void toggle() {
    _vpnOn = !_vpnOn;
    notifyListeners();
  }

  void updateBandwidthUsage(
      int bandwidthUsed, int dataCap, DateTime capResetsAt) {
    _bandwidthUsed = bandwidthUsed;
    _dataCap = dataCap;
    _capResetsAt = capResetsAt;
    notifyListeners();
  }
}

import 'dart:io';
import 'package:lantern/replica/models/replica_model.dart';

// This class works like this:
// - Always use it in static form. Don't instantiate it
// - Call 'await ReplicaCommon.init()' sometime during app initialization
// - Then, use any method here you like. An exception will occur if 'await
//   ReplicaCommon.init()' was never called at least once
class ReplicaCommon {
  static final _replicaModel = ReplicaModel();
  static bool _didCallInit = false;
  static String? _replicaAddr;

  /// init() calls replicaModel.getReplicaAddr() with a timeout delay and caches
  /// its value locally.
  ///
  /// This basically 'un-futures' replicaModel.getReplicaAddr(), so that the
  /// rest of the program does not have to always call a future (i.e.,
  /// replicaModel.getReplicaAddr()), which uses MethodChannels (can be
  /// expensive) to fetch replicaAddr.
  ///
  /// If we find _replicaAddr here to be null, never use Replica in the app.
  /// In practice, this is a rare case.
  ///
  /// Calling init() multiple times is harmless.
  static Future<void> init() async {
    if (_didCallInit) {
      return;
    }
    // Only accept android
    if (!Platform.isAndroid) {
      _didCallInit = true;
      return;
    }

    try {
      _replicaAddr = await _replicaModel
          .getReplicaAddr()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      _replicaAddr = null;
    }
    _didCallInit = true;
    return;
  }

  static bool isReplicaRunning() {
    if (!_didCallInit) {
      throw Exception('ReplicaCommon.init() was never called');
    }
    return Platform.isAndroid && _replicaAddr != null;
  }

  static String? getReplicaServerAddr() {
    if (!_didCallInit) {
      throw Exception('ReplicaCommon.init() was never called');
    }
    return _replicaAddr;
  }
}

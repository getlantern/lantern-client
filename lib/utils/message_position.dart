import 'package:flutter/material.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';

class MessagePosition {
  static double position(Widget? widget, StoredMessage? nexMessage,
      StoredMessage? priorMessage, bool inbound, bool outbound) {
    if (widget != null) return 16.0;
    if (outbound &&
        nexMessage != null &&
        nexMessage.direction == MessageDirection.IN) return 6.0;
    if (outbound && nexMessage != null && priorMessage != null) return 2.0;
    if (inbound &&
        nexMessage != null &&
        nexMessage.direction == MessageDirection.OUT) return 6.0;
    if (inbound && nexMessage != null && priorMessage != null) return 2.0;
    if (nexMessage == null) return 8.0;
    return 0.0;
  }
}

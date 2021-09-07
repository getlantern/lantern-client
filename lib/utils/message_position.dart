import 'package:flutter/material.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';

class MessagePosition {
  //Returns the padding based on multiple conditions such as: Direction of the message, reactions, has previous bubble, has new bubble
  static double topPosition(Widget? widget, StoredMessage? nexMessage,
      StoredMessage? priorMessage, bool inbound, bool outbound) {
    if (priorMessage == null && nexMessage != null) return 15.0;
    return 0.0;
  }

//Returns the padding based on multiple conditions such as: Direction of the message, reactions, has previous bubble, has new bubble
  static double bottomPosition(Widget? widget, StoredMessage? nexMessage,
      StoredMessage? priorMessage, bool inbound, bool outbound) {
    if (nexMessage != null && nexMessage.reactions.isNotEmpty) {
      return 16.0;
    }
    if (outbound &&
        nexMessage != null &&
        nexMessage.direction == MessageDirection.IN) return 6.0;
    if (outbound && nexMessage != null && priorMessage != null) return 2.0;
    if (inbound &&
        nexMessage != null &&
        nexMessage.direction == MessageDirection.OUT) return 6.0;
    if (inbound && nexMessage != null && priorMessage != null) return 2.0;
    if (nexMessage == null) return 8.0;
    return 2.0;
  }
}

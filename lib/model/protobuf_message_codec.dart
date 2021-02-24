import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:protobuf/protobuf.dart';

import 'protos/messaging.pb.dart';

class ProtobufMessageCodec extends StandardMessageCodec {
  static const int _valueTimestamp = 30;
  static const int _valueContact = 31;
  static const int _valueMessage = 32;
  static const int _valueConversation = 33;

  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value == null) {
      super.writeValue(buffer, value);
      return;
    }

    int type = 0;
    switch (value.runtimeType) {
      case Timestamp:
        type = _valueTimestamp;
        break;
      case Contact:
        type = _valueContact;
        break;
      case Message:
        type = _valueMessage;
        break;
      case Conversation:
        type = _valueConversation;
        break;
    }

    if (type == 0) {
      super.writeValue(buffer, value);
      return;
    }

    buffer.putUint8(type);
    var serialized = (value as GeneratedMessage).writeToBuffer();
    writeSize(buffer, serialized.length);
    buffer.putUint8List(serialized);
  }

  dynamic readValueOfType(int type, ReadBuffer buffer) {
    if (type < 30) {
      return super.readValueOfType(type, buffer);
    }

    final int length = readSize(buffer);
    var serialized = buffer.getUint8List(length);
    switch (type) {
      case _valueTimestamp:
        return Conversation.fromBuffer(serialized);
      case _valueContact:
        return Contact.fromBuffer(serialized);
      case _valueMessage:
        return Message.fromBuffer(serialized);
      case _valueConversation:
        return Conversation.fromBuffer(serialized);
      default:
        throw FormatException("Unknown data type $type");
    }
  }
}

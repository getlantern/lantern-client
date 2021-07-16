import 'package:flutter/material.dart';
import 'package:lantern/enums/enum_extension.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

enum MimeTypes { VIDEO, AUDIO, OTHERS, EMPTY }

class MimeReply {
  static Widget reply(StoredMessage? storedMessage) {
    if (storedMessage?.attachments == null ||
        storedMessage!.attachments.isEmpty) {
      return const SizedBox();
    }

    final _mimeType = storedMessage.attachments[0]!.attachment.fromString();
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (MimeTypes.AUDIO == _mimeType)
            ? const Text('AUDIO')
            : const Text('VIDEO'),
      ],
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lantern/config/colors.dart';
import 'package:lantern/enums/enum_extension.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/lru_cache.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/ui/widgets/basic_memory_image.dart';

enum MimeTypes { VIDEO, AUDIO, IMAGE, OTHERS, EMPTY }

class ReplyMime extends StatelessWidget {
  const ReplyMime({required this.storedMessage, required this.model}) : super();

  final StoredMessage storedMessage;
  final MessagingModel model;

  @override
  Widget build(BuildContext context) {
    final _mimeType = storedMessage.attachments[0]!.attachment.fromString();

    switch (_mimeType) {
      case MimeTypes.AUDIO:
        return _getIconWrapper(Icons.volume_up);
      case MimeTypes.VIDEO:
        return _PreviewBuilder(
          valueListenable:
              model.thumbnail(storedMessage.attachments[0] as StoredAttachment),
          builder: (BuildContext context, Uint8List data) =>
              Stack(alignment: Alignment.center, children: [
            BasicMemoryImage(data,
                errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) =>
                    _getIconWrapper(Icons.error_outlined),
                height: 56),
            const Icon(Icons.play_circle_outline, color: Colors.white),
          ]),
        );
      case MimeTypes.IMAGE:
        return _PreviewBuilder(
          valueListenable:
              model.thumbnail(storedMessage.attachments[0] as StoredAttachment),
          builder: (BuildContext context, Uint8List data) => BasicMemoryImage(
              data,
              errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) =>
                  _getIconWrapper(Icons.error_outlined),
              height: 56),
        );
      case MimeTypes.OTHERS:
      case MimeTypes.EMPTY:
      default:
        return Container(
          color: grey5,
          padding: const EdgeInsets.all(8.0),
          child: const Icon(
            Icons.insert_drive_file_rounded,
            size: 18,
            color: Colors.white,
          ),
        );
    }
  }
}

class _PreviewBuilder<T> extends ValueListenableBuilder<CachedValue<T>> {
  _PreviewBuilder({
    Key? key,
    required ValueListenable<CachedValue<T>> valueListenable,
    required Widget Function(BuildContext context, T value) builder,
  }) : super(
            key: key,
            valueListenable: valueListenable,
            builder: (BuildContext context, CachedValue<T> cachedValue,
                Widget? child) {
              if (cachedValue.error != null) {
                return _getIconWrapper(Icons.error_outlined);
              } else if (cachedValue.value == null) {
                return const SizedBox();
              } else {
                return builder(context, cachedValue.value!);
              }
            });
}

Widget _getIconWrapper(IconData icon) {
  return Container(
    color: grey5,
    padding: const EdgeInsets.all(8.0),
    child: Icon(
      icon,
      size: 18,
      color: Colors.white,
    ),
  );
}

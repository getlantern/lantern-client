import 'dart:typed_data';
import 'package:lantern/config/colors.dart';

import 'package:flutter/material.dart';
import 'package:lantern/enums/enum_extension.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

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
        return _resolveFuture('audio');
      case MimeTypes.VIDEO:
        return _resolveFuture('video');
      case MimeTypes.IMAGE:
        return _resolveFuture('image');
      case MimeTypes.OTHERS:
      case MimeTypes.EMPTY:
      default:
        return _getDefaultWidget();
    }
  }

  Container _getDefaultWidget() {
    return Container(
      color: snippetBgIconColor,
      padding: const EdgeInsets.all(8.0),
      child: const Icon(
        Icons.insert_drive_file_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  FutureBuilder<Uint8List> _resolveFuture(String mimeType) {
    return FutureBuilder(
        future: model.decryptAttachment(
            storedMessage.attachments[0] as StoredAttachment),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?>? snapshot) {
          // there is an error with the future
          if (snapshot == null || !snapshot.hasData) {
            return _getIconWrapper(Icons.error_outlined);
          }
          // the future will return correctly, look up mime types to determine UI
          switch (mimeType) {
            case 'image':
              return Image.memory(snapshot.data!,
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      _getIconWrapper(Icons.error_outlined),
                  filterQuality: FilterQuality.high,
                  height: 56);
            case 'video':
              return Stack(alignment: Alignment.center, children: [
                Image.memory(snapshot.data!,
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) =>
                        _getIconWrapper(Icons.error_outlined),
                    filterQuality: FilterQuality.high,
                    height: 56),
                const Icon(Icons.play_circle_outline, color: Colors.white),
              ]);
            case 'audio':
              return _getIconWrapper(Icons.volume_up);
            default:
              return _getDefaultWidget();
          }
        });
  }

  Widget _getIconWrapper(IconData icon) {
    return Container(
      color: snippetBgIconColor,
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

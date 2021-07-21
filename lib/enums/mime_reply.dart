import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lantern/enums/enum_extension.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/utils/waveform/waveform.dart';
import 'package:lantern/utils/duration_extension.dart';
import 'package:sizer/sizer.dart';

enum MimeTypes { VIDEO, AUDIO, IMAGE, OTHERS, EMPTY }

class MimeReply {
  static Widget reply(
      {StoredMessage? storedMessage,
      required MessagingModel model,
      required BuildContext context}) {
    if (storedMessage?.attachments == null ||
        storedMessage!.attachments.isEmpty) {
      return const SizedBox();
    }
    var _seconds = 0;
    var _audioDuration = Duration.zero;
    final _mimeType = storedMessage.attachments[0]!.attachment.fromString();
    if (MimeTypes.AUDIO == _mimeType) {
      _seconds = (double.tryParse(
                  (storedMessage.attachments[0] as StoredAttachment)
                      .attachment
                      .metadata['duration']!)! *
              1000)
          .toInt();
      _audioDuration = Duration(milliseconds: _seconds);
    }
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          storedMessage.attachments[0]!.attachment.mimeType.split('/')[0],
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        (MimeTypes.AUDIO == _mimeType)
            ? Text(
                'Time: (${_audioDuration.time(minute: true, seconds: true)})',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              )
            : const SizedBox(),
        (MimeTypes.AUDIO == _mimeType)
            ? FutureBuilder(
                future: model.decryptAttachment(
                    storedMessage.attachments[0] as StoredAttachment),
                builder: (BuildContext context,
                        AsyncSnapshot<Uint8List?>? snapshot) =>
                    snapshot == null || !snapshot.hasData
                        ? const SizedBox()
                        : Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: CustomPaint(
                                painter: Waveform(
                                  waveData: snapshot.data!,
                                  gap: 1,
                                  density: 100,
                                  height: 100,
                                  width: 120,
                                  startingHeight: 5,
                                  finishedHeight: 5.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
              )
            : (MimeTypes.VIDEO == _mimeType || MimeTypes.IMAGE == _mimeType)
                ? FutureBuilder(
                    future: model.thumbnail(
                        storedMessage.attachments[0] as StoredAttachment),
                    builder: (BuildContext context,
                            AsyncSnapshot<Uint8List?>? snapshot) =>
                        snapshot == null || !snapshot.hasData
                            ? const Icon(Icons.error_outlined)
                            : Image.memory(snapshot.data!,
                                errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) =>
                                    const Icon(Icons.error_outlined),
                                filterQuality: FilterQuality.high,
                                scale: 10),
                  )
                : const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 30,
                  ),
      ],
    );
  }

  // Generate a waveform from an audio file.
}

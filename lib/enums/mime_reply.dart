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
      {required StoredMessage storedMessage,
      required MessagingModel model,
      required BuildContext context}) {
    // return Text reply first
    if (storedMessage.attachments.isEmpty) {
      return Flexible(
          fit: FlexFit.tight,
          child: Text(storedMessage.text, overflow: TextOverflow.ellipsis));
    }
    final _mimeType = storedMessage.attachments[0]!.attachment.fromString();

    // not currently in use but might be needed in the future
    // var _seconds = 0;
    // var _audioDuration = Duration.zero;
    // if (MimeTypes.AUDIO == _mimeType) {
    //   _seconds = (double.tryParse(
    //               (storedMessage.attachments[0] as StoredAttachment)
    //                   .attachment
    //                   .metadata['duration']!)! *
    //           1000)
    //       .toInt();
    //   _audioDuration = Duration(milliseconds: _seconds);
    // }
    switch (_mimeType) {
      case MimeTypes.AUDIO:
        return FutureBuilder(
            future: model.decryptAttachment(
                storedMessage.attachments[0] as StoredAttachment),
            builder:
                (BuildContext context, AsyncSnapshot<Uint8List?>? snapshot) =>
                    snapshot == null || !snapshot.hasData
                        ? const Icon(
                            Icons.error,
                            size: 30,
                          )
                        : const Icon(
                            Icons.audiotrack,
                            size: 30,
                          ));
      case MimeTypes.VIDEO:
      case MimeTypes.IMAGE:
        return FutureBuilder(
          future:
              model.thumbnail(storedMessage.attachments[0] as StoredAttachment),
          builder:
              (BuildContext context, AsyncSnapshot<Uint8List?>? snapshot) =>
                  snapshot == null || !snapshot.hasData
                      ? const Icon(Icons.error_outlined, size: 30)
                      : Image.memory(snapshot.data!,
                          errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) =>
                              const Icon(Icons.error_outlined),
                          filterQuality: FilterQuality.high,
                          scale: 10),
        );
      case MimeTypes.OTHERS:
      case MimeTypes.EMPTY:
      default:
        return const Icon(
          Icons.insert_drive_file_rounded,
          color: Colors.black,
          size: 30,
        );
        ;
    }
  }
}

// Not currently in use, but we might need it in the future
// class audioPreviewDeprecated extends StatelessWidget {
//   const audioPreviewDeprecated({
//     Key? key,
//     required Duration audioDuration,
//   }) : _audioDuration = audioDuration, super(key: key);

//   final Duration _audioDuration;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 40,
//             width: MediaQuery.of(context).size.width * 0.5,
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: CustomPaint(
//                 painter: Waveform(
//                   waveData: snapshot.data!,
//                   gap: 1,
//                   density: 100,
//                   height: 100,
//                   width: 120,
//                   startingHeight: 5,
//                   finishedHeight: 5.5,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//           Text(
//             _audioDuration.time(minute: true, seconds: true),
//             style: TextStyle(
//               fontSize: 10.sp,
//               fontWeight: FontWeight.w400,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       );
//   }
// }

import 'dart:typed_data';
import 'package:lantern/config/colors.dart';

import 'package:flutter/material.dart';
import 'package:lantern/enums/enum_extension.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

enum MimeTypes { VIDEO, AUDIO, IMAGE, OTHERS, EMPTY }

class ReplyMime extends StatelessWidget {
  const ReplyMime({required this.storedMessage, required this.model}) : super();

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

  final StoredMessage storedMessage;
  final MessagingModel model;

  @override
  Widget build(BuildContext context) {
    final _mimeType = storedMessage.attachments[0]!.attachment.fromString();

    final Widget errorCaseWidget = Container(
      color: snippetBgIconColor,
      padding: const EdgeInsets.all(8.0),
      child: const Icon(
        Icons.error_outlined,
        size: 18,
        color: Colors.white,
      ),
    );

    switch (_mimeType) {
      case MimeTypes.AUDIO:
        return FutureBuilder(
            future: model.decryptAttachment(
                storedMessage.attachments[0] as StoredAttachment),
            builder:
                (BuildContext context, AsyncSnapshot<Uint8List?>? snapshot) =>
                    snapshot == null || !snapshot.hasData
                        ? const Icon(
                            Icons.error_outlined,
                            size: 18,
                          )
                        : const Icon(
                            Icons.volume_up,
                            size: 18,
                          ));
      case MimeTypes.VIDEO:
        return FutureBuilder(
          future:
              model.thumbnail(storedMessage.attachments[0] as StoredAttachment),
          builder:
              (BuildContext context, AsyncSnapshot<Uint8List?>? snapshot) =>
                  snapshot == null || !snapshot.hasData
                      ? errorCaseWidget
                      : Stack(alignment: Alignment.center, children: [
                          Image.memory(snapshot.data!,
                              errorBuilder: (BuildContext context, Object error,
                                      StackTrace? stackTrace) =>
                                  errorCaseWidget,
                              filterQuality: FilterQuality.high,
                              height: 56),
                          const Icon(Icons.play_circle_outline,
                              color: Colors.white),
                        ]),
        );
      case MimeTypes.IMAGE:
        return FutureBuilder(
          future:
              model.thumbnail(storedMessage.attachments[0] as StoredAttachment),
          builder:
              (BuildContext context, AsyncSnapshot<Uint8List?>? snapshot) =>
                  snapshot == null || !snapshot.hasData
                      ? errorCaseWidget
                      : Image.memory(snapshot.data!,
                          errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) =>
                              errorCaseWidget,
                          filterQuality: FilterQuality.high,
                          height: 56),
        );
      case MimeTypes.OTHERS:
      case MimeTypes.EMPTY:
      default:
        return errorCaseWidget;
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

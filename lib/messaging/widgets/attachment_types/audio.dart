import 'dart:typed_data';

import 'package:lantern/messaging/widgets/attachment.dart';
import 'package:lantern/messaging/widgets/voice_recorder/audio_widget.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:sizer/sizer.dart';

/// An attachment that shows an audio player.
class AudioAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  AudioAttachment(this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    return AttachmentBuilder(
        attachment: attachment,
        inbound: inbound,
        padAttachment: false,
        defaultIcon: Icons.image,
        builder: (BuildContext context, Uint8List thumbnail) {
          return AudioWidget(
            controller: AudioController(
                context: context,
                barsLimit: 80,
                attachment: attachment,
                thumbnail: thumbnail),
            inbound: inbound,
            initialColor: inbound ? Colors.black : Colors.white,
            progressColor: inbound ? outboundMsgColor : inboundMsgColor,
            backgroundColor: inbound ? inboundBgColor : outboundBgColor,
            widgetWidth: 70.w,
            gap: 0.7,
            waveHeight: 39,
            widgetHeight: 40,
          );
        });
  }
}

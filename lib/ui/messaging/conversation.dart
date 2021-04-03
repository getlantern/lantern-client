import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/messaging/attachment.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Conversation extends StatefulWidget {
  final Contact _contact;

  Conversation(this._contact) : super();

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  MessagingModel model;

  final TextEditingController _newMessage = TextEditingController();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  var _recording = false;
  var _willCancelRecording = false;
  var _totalPanned = 0.0;

  @override
  void dispose() {
    _newMessage.dispose();
    super.dispose();
  }

  Widget buildMessage(BuildContext context, PathAndValue<StoredMessage> message,
      StoredMessage priorMessage, StoredMessage nextMessage) {
    return model.message(context, message,
        (BuildContext context, StoredMessage msg, Widget child) {
      var outbound = msg.direction == MessageDirection.OUT;
      var inbound = !outbound;

      var statusRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.5,
            child: Text(
              message.value.ts.toInt().humanizedDate(),
              style: TextStyle(
                color: outbound ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );

      var innerColumn = Column(
          crossAxisAlignment:
              outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (msg.text?.isNotEmpty)
                Flexible(
                  child: Text(
                    "${msg.text}",
                    style: TextStyle(
                      color: outbound ? Colors.white : Colors.black,
                    ),
                  ),
                ),
            ]),
          ]);

      innerColumn.children.addAll(msg.attachments.values
          .map((attachment) => attachmentWidget(attachment)));
      innerColumn.children.add(statusRow);

      var statusIcon = inbound
          ? null
          : msg.status == StoredMessage_DeliveryStatus.SENDING
              ? Icons.pending_outlined
              : msg.status == StoredMessage_DeliveryStatus.COMPLETELY_FAILED ||
                      msg.status ==
                          StoredMessage_DeliveryStatus.PARTIALLY_FAILED
                  ? Icons.error_outline
                  : null;
      if (statusIcon != null) {
        statusRow.children
            .add(Transform.scale(scale: .5, child: Icon(statusIcon)));
      }
      var startOfBlock = priorMessage == null ||
          priorMessage.direction != message.value.direction;
      var endOfBlock = nextMessage == null ||
          nextMessage.direction != message.value.direction;
      var newestMessage = nextMessage == null;
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                  left: outbound ? 20 : 4,
                  right: outbound ? 4 : 20,
                  top: 4,
                  bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: outbound ? Colors.black38 : Colors.black12,
                  borderRadius: BorderRadius.only(
                    topLeft: inbound && !startOfBlock
                        ? Radius.zero
                        : Radius.circular(5),
                    topRight: outbound && !startOfBlock
                        ? Radius.zero
                        : Radius.circular(5),
                    bottomRight: outbound && (!endOfBlock || newestMessage)
                        ? Radius.zero
                        : Radius.circular(5),
                    bottomLeft: inbound && (!endOfBlock || newestMessage)
                        ? Radius.zero
                        : Radius.circular(5),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                  child: innerColumn,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  _send(String text, {List<Uint8List> attachments}) {
    model.sendToDirectContact(widget._contact.id,
        text: text, attachments: attachments);
    _newMessage.clear();
  }

  _startRecording() {
    if (_recording) {
      return;
    }

    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    setState(() {
      _recording = true;
      _totalPanned = 0;
    });
    model.startRecordingVoiceMemo();
  }

  _finishRecording() async {
    if (!_recording) {
      return;
    }

    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    var attachment = await model.stopRecordingVoiceMemo();
    if (!_willCancelRecording) {
      _send(_newMessage.value.text, attachments: [attachment]);
    }
    setState(() {
      _recording = false;
      _willCancelRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();

    return BaseScreen(
      title: widget._contact.displayName.isEmpty
          ? widget._contact.id
          : widget._contact.displayName,
      body: GestureDetector(
        child: Stack(children: [
          Column(children: [
            Expanded(
              child: model.contactMessages(widget._contact, builder: (context,
                  Iterable<PathAndValue<StoredMessage>> messageRecords,
                  Widget child) {
                return ListView.builder(
                  reverse: true,
                  itemCount: messageRecords.length,
                  itemBuilder: (context, index) {
                    return buildMessage(
                        context,
                        messageRecords.elementAt(index),
                        index >= messageRecords.length - 1
                            ? null
                            : messageRecords.elementAt(index + 1).value,
                        index == 0
                            ? null
                            : messageRecords.elementAt(index - 1).value);
                  },
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Divider(height: 3),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: _send,
                    controller: _newMessage,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            var text = _newMessage.value.text;
                            if (text.isEmpty) {
                              return;
                            }
                            _send(text);
                          }),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Message'.i18n,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Icon(Icons.mic),
                  onTapDown: (details) {
                    _startRecording();
                  },
                  onTapUp: (details) async {
                    await _finishRecording();
                  },
                )
              ]),
            ),
          ]),
          if (_recording)
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Flexible(
                child: ColoredBox(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 17),
                        child: Icon(Icons.circle, color: Colors.red),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 22),
                        child: StreamBuilder<int>(
                          stream: _stopWatchTimer.rawTime,
                          initialData:
                              _stopWatchTimer.rawTime.valueWrapper?.value,
                          builder: (context, snap) {
                            final value = snap.data;
                            final displayTime = StopWatchTimer.getDisplayTime(
                                value,
                                minute: true,
                                second: true,
                                hours: false,
                                milliSecond: false);
                            return Text(displayTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold));
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          height: 63,
                          child: Padding(
                              padding: EdgeInsets.only(right: 24),
                              child: Text(
                                  _willCancelRecording
                                      ? 'will cancel'.i18n
                                      : '< ' + 'swipe to cancel'.i18n,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                        ),
                      ),
                      GestureDetector(
                        child: Transform.scale(
                          scale: 2,
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(38)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 15, top: 15, right: 4, bottom: 4),
                              child: Icon(Icons.mic_none),
                            ),
                          ),
                        ),
                        onTapUp: (details) async {
                          await _finishRecording();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]),
        ]),
        onPanUpdate: (details) {
          _totalPanned += details.delta.dx;
          if (!_willCancelRecording && _totalPanned < -19) {
            setState(() {
              _willCancelRecording = true;
            });
          } else if (_willCancelRecording && _totalPanned > -19) {
            setState(() {
              _willCancelRecording = false;
            });
          }
        },
        onPanEnd: (details) async {
          await _finishRecording();
        },
      ),
    );
  }
}

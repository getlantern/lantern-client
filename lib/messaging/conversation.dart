import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/disappearing_timer_action.dart';
import 'package:lantern/messaging/widgets/message_bubble.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Conversation extends StatefulWidget {
  final Contact _contact;

  Conversation(this._contact) : super();

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  late MessagingModel model;

  final TextEditingController _newMessage = TextEditingController();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  var _recording = false;
  var _willCancelRecording = false;
  var _totalPanned = 0.0;

  @override
  void dispose() {
    _newMessage.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  void _send(String text, {List<Uint8List>? attachments}) {
    model.sendToDirectContact(widget._contact.contactId.id,
        text: text, attachments: attachments);
    _newMessage.clear();
  }

  void _startRecording() {
    if (_recording) {
      return;
    }

    model.startRecordingVoiceMemo().then((value) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      setState(() {
        _recording = true;
        _totalPanned = 0;
      });
    });
  }

  Future<void> _finishRecording() async {
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

  Future<void> _selectFilesToShare() async {
    try {
      var pickedFile = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);

      if (pickedFile != null) {
        var filePath = pickedFile.files.first.path;
        var fileExtension = pickedFile.files.first.extension;
        var fileSize = pickedFile.files.first.size;
        var attachment = await model.filePickerLoadAttachment(
            filePath, fileExtension, fileSize);
        _send(_newMessage.value.text, attachments: [attachment]);
      } else {
        print('User has cancelled the selection');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    return BaseScreen(
      title: widget._contact.displayName.isEmpty
          ? widget._contact.contactId.id
          : widget._contact.displayName,
      actions: [DisappearingTimerAction(widget._contact)],
      body: GestureDetector(
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
        child: Stack(children: [
          Column(children: [
            Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: model.singleContact(
                    context,
                    widget._contact,
                    (context, contact, child) => contact
                                .messagesDisappearAfterSeconds >
                            0
                        ? Text(
                            'New messages disappear after ${contact.messagesDisappearAfterSeconds.humanizeSeconds(longForm: true)}')
                        : Container())),
            Expanded(
              child: model.contactMessages(widget._contact, builder: (context,
                  Iterable<PathAndValue<StoredMessage>> messageRecords,
                  Widget? child) {
                return ListView.builder(
                  reverse: true,
                  itemCount: messageRecords.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
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
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Divider(height: 3),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: _send,
                    controller: _newMessage,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
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
                  onTap: () {
                    _selectFilesToShare();
                  },
                  child: const Icon(Icons.image),
                ),
                GestureDetector(
                  onTapDown: (details) {
                    _startRecording();
                  },
                  onTapUp: (details) async {
                    await _finishRecording();
                  },
                  child: const Icon(Icons.mic),
                ),
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
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 17),
                        child: Icon(Icons.circle, color: Colors.red),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 22),
                        child: StreamBuilder<int>(
                          stream: _stopWatchTimer.rawTime,
                          initialData:
                              _stopWatchTimer.rawTime.valueWrapper?.value,
                          builder: (context, snap) {
                            final value = snap.data;
                            final displayTime = StopWatchTimer.getDisplayTime(
                                value ?? 0,
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
                              padding: const EdgeInsets.only(right: 24),
                              child: Text(
                                  _willCancelRecording
                                      ? 'will cancel'.i18n
                                      : '< ' + 'swipe to cancel'.i18n,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (details) async {
                          await _finishRecording();
                        },
                        child: Transform.scale(
                          scale: 2,
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(38)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  left: 15, top: 15, right: 4, bottom: 4),
                              child: Icon(Icons.mic_none),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
        ]),
      ),
    );
  }
}

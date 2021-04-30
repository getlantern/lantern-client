import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/disappearing_timer_action.dart';
import 'package:lantern/messaging/widgets/message_bubble.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:lantern/messaging/widgets/filepicker_extensions.dart';
import 'package:../wechat_assets_picker/wechat_assets_picker.dart';

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

  // Filepicker vars
  final int maxAssetsCount = 9;
  List<AssetEntity> assets = <AssetEntity>[];
  bool isDisplayingDetail = true;
  ThemeData get currentTheme => context.themeData;

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

  Future<List<AssetEntity>?> _renderFilePicker() async {
    AssetPicker.registerObserve();
    return await AssetPicker.pickAssets(
      context,
      maxAssets: maxAssetsCount,
      selectedAssets: assets,
      // pickerTheme: ThemeData.dark(),
      // themeColor: currentTheme.accentColor,
      textDelegate:
          EnglishTextDelegate(), // DefaultAssetsPickerTextDelegate for Chinese
      requestType: RequestType.all,
      specialItemPosition: SpecialItemPosition.prepend,
      specialItemBuilder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final result = await CameraPicker.pickFromCamera(
              context,
              enableRecording: true,
            );
            if (result != null) {
              Navigator.of(context).pop(<AssetEntity>[result]);
            }
          },
          child: const Center(
            child: Icon(Icons.camera_alt, size: 30.0),
          ),
        );
      },
    );
  }

  Future<void> _selectFilesToShare() async {
    try {
      var pickedAssets = await _renderFilePicker();
      if (pickedAssets == null) {
        return;
      }
      //
      // Here is an example of an AssetEntity:
      //
      // _latitude:null
      // _longitude:null
      // createDtSecond:1618960950
      // duration:0
      // height:600
      // id:"62"
      // isFavorite:false
      // mimeType:"image/jpeg"
      // modifiedDateSecond:1618960950
      // orientation:0
      // relativePath:"Download/"
      // title:"original_3f30a68a04a1d9529da9e2219458c7bd.jpg"
      // typeInt:1
      // width:800
      // createDateTime:DateTime (2021-04-20 19:22:30.000)
      // exists:_Future (Instance of 'Future<bool>')
      // file:_Future (Instance of 'Future<File?>')
      // fullData:_Future (Instance of 'Future<Uint8List?>')
      // hashCode:614304830
      // latitude:0.0
      // longitude:0.0
      // modifiedDateTime:DateTime (2021-04-20 19:22:30.000)
      // originBytes:_Future (Instance of 'Future<Uint8List?>')
      // originFile:_Future (Instance of 'Future<File?>')
      // runtimeType:Type (AssetEntity)
      // size:Size (Size(800.0, 600.0))
      // thumbData:_Future (Instance of 'Future<Uint8List?>')
      // titleAsync:_Future (Instance of 'Future<String>')
      // type:AssetType (AssetType.image)
      // videoDuration:Duration (0:00:00.000000)

      var pickedFile = pickedAssets.first;
      var absolutePath = await pickedFile.originFile
          .then((file) async => file?.path) as String;
      var attachment = await model.filePickerLoadAttachment(absolutePath);
      _send(_newMessage.value.text, attachments: [attachment]);
    } catch (e) {
      // TODO: display error pop up
      print(e);
    }
    AssetPicker.unregisterObserve();
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
                  onTap: () => _selectFilesToShare(),
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

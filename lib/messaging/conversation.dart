import 'dart:typed_data';
import 'dart:ui';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/disappearing_timer_action.dart';
import 'package:lantern/messaging/widgets/message_bar.dart';
import 'package:lantern/messaging/widgets/message_bubble.dart';
import 'package:lantern/messaging/widgets/messaging_emoji_picker.dart';
import 'package:lantern/messaging/widgets/staging_container_item.dart';
import 'package:lantern/messaging/widgets/voice_recorder.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/model/tab_status.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:sizer/sizer.dart';

class Conversation extends StatefulWidget {
  final Contact _contact;

  Conversation(this._contact) : super();

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation>
    with WidgetsBindingObserver {
  late MessagingModel model;
  Size? size;
  late final ShowEmojis onEmojiTap;
  bool _customEmojiResponse = false;
  bool _hasPermission = false;

  final TextEditingController _newMessage = TextEditingController();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool _recording = false;
  bool _willCancelRecording = false;
  bool _isSendIconVisible = false;
  bool _isReplying = false;
  StoredMessage? _quotedMessage;
  var displayName = '';
  bool _emojiShowing = false;
  final _focusNode = FocusNode();
  PathAndValue<StoredMessage>? _storedMessage;
  final _scrollController = ItemScrollController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        model.clearCurrentConversationContact();
        break;
      case AppLifecycleState.resumed:
      default:
        model.setCurrentConversationContact(widget._contact.contactId.id);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    displayName = widget._contact.displayName.isEmpty
        ? widget._contact.contactId.id
        : widget._contact.displayName;
    BackButtonInterceptor.add(_interceptBackButton);
    WidgetsBinding.instance!.addObserver(this);
  }

  // Filepicker vars
  List<AssetEntity> assets = <AssetEntity>[];

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _newMessage.dispose();
    _stopWatchTimer.dispose();
    _focusNode.dispose();
    BackButtonInterceptor.remove(_interceptBackButton);
    super.dispose();
  }

  bool _interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
    if (_emojiShowing) {
      setState(() => _emojiShowing = false);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _send(String text,
      {List<Uint8List>? attachments,
      String? replyToSenderId,
      String? replyToId}) async {
    await model.sendToDirectContact(
      widget._contact.contactId.id,
      text: text,
      attachments: attachments,
      replyToId: replyToId,
      replyToSenderId: replyToSenderId,
    );
    _newMessage.clear();
    setState(() => _quotedMessage = null);
    // scroll to bottom on send
    // the error is due to this segment of the code, it's appear that the assertion is not true
    // and when the scroll tries to display the new message breaks.
    // await _scrollController.scrollTo(
    //     index: 00,
    //     duration: const Duration(seconds: 1),
    //     curve: Curves.easeInOutCubic);
  }

  Future<void> _startRecording() async {
    if (_recording) {
      return;
    }
    _hasPermission = await model.startRecordingVoiceMemo();
    if (_hasPermission) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      setState(() {
        _recording = true;
      });
    }
  }

  Future<void> _finishRecording() async {
    if (!_recording) {
      return;
    }

    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    var attachment = await model.stopRecordingVoiceMemo();
    if (!_willCancelRecording) {
      await _send(_newMessage.value.text, attachments: [attachment]);
    }
    setState(() {
      _recording = false;
      _willCancelRecording = false;
    });
  }

  void showKeyboard() => _focusNode.requestFocus();
  Future<List<AssetEntity>?> _renderFilePicker() async {
    AssetPicker.registerObserve();
    return await AssetPicker.pickAssets(
      context,
      selectedAssets: assets,
      textDelegate: EnglishTextDelegate(),
      // DefaultAssetsPickerTextDelegate for Chinese
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
          // TODO(kallirroi): Refine the UI/UX
          child: const Center(
            child: Icon(Icons.camera),
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
      // NOTE: An example of an AssetEntity object:
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

      pickedAssets.forEach((el) async {
        final absolutePath =
            await el.originFile.then((file) async => file?.path) as String;
        final metadata = {'title': el.title as String};
        final attachment =
            await model.filePickerLoadAttachment(absolutePath, metadata);
        await _send(_newMessage.value.text, attachments: [attachment]);
      });
    } catch (e) {
      showInfoDialog(
        context,
        title: 'Error'.i18n,
        // TODO: Add i18n below
        des: 'Something went wrong while sharing a media file.',
      );
    }
    AssetPicker.unregisterObserve();
  }

  void dismissKeyboard() {
    _focusNode.unfocus();
  }

  Future<void> _handleSubmit(TextEditingController _newMessage) async {
    setState(() {
      _isSendIconVisible = false;
      _isReplying = false;
      _emojiShowing = false;
    });
    await _send(_newMessage.value.text,
        replyToSenderId: _quotedMessage?.senderId,
        replyToId: _quotedMessage?.id);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    model = context.watch<MessagingModel>();
    var tabStatus = context.watch<TabStatus>();
    if (tabStatus.active) {
      unawaited(
          model.setCurrentConversationContact(widget._contact.contactId.id));
    } else {
      unawaited(model.clearCurrentConversationContact());
    }
    return BaseScreen(
        // Conversation title (contact name)
        title: displayName,
        actions: [DisappearingTimerAction(widget._contact)],
        body: Stack(children: [
          Flex(
            direction: Axis.vertical,
            children: [
              // const Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5)),
              // // Conversation header
              // Card(
              //     color: Colors.white70,
              //     child: Column(
              //       children: [
              //         Container(
              //           width: 75.w,
              //           height: 15.h,
              //           child:
              //               const Icon(Icons.account_circle_rounded, size: 140),
              //         ),
              //         Container(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 15, vertical: 15),
              //             child: Text(widget._contact.displayName,
              //                 style: const TextStyle(fontSize: 25))),
              //       ],
              //     )),
              // Message Retention
              Card(
                color: Colors.white70,
                child: Container(
                  width: 70.w,
                  child: _buildMessagesLifeExpectancy(),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: _buildMessageBubbles(),
              ),
              // Reply container
              if (_isReplying)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: StagingContainerItem(
                    quotedMessage: _quotedMessage,
                    model: model,
                    contact: widget._contact,
                    onCloseListener: () => setState(() => _isReplying = false),
                  ),
                ),
              const Divider(height: 1.0),
              Padding(
                padding: _recording
                    ? const EdgeInsets.only(top: 4.0, right: 0, left: 0)
                    : const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 2.0),
                child: MessageBar(
                  width: size!.width,
                  isRecording: _recording,
                  stopWatchTimer: _stopWatchTimer,
                  onSwipeLeft: () async {
                    await model.stopRecordingVoiceMemo();
                    setState(() => _recording = false);
                  },
                  onTapUpListener: () async => await _finishRecording(),
                  willCancelRecording: _willCancelRecording,
                  height: 45,
                  sendIcon: _isSendIconVisible,
                  hasPermission: _hasPermission,
                  onFileSend: () async => await _selectFilesToShare(),
                  onFieldSubmitted: (value) async =>
                      value.isEmpty ? null : await _handleSubmit(_newMessage),
                  onTextFieldChanged: (value) =>
                      setState(() => _isSendIconVisible = value.isNotEmpty),
                  onSend: () => _handleSubmit(_newMessage),
                  onRecording: () async => await _startRecording(),
                  onStopRecording: () async =>
                      _hasPermission ? await _finishRecording() : null,
                  onTextFieldTap: () => setState(() => _emojiShowing = false),
                  messageController: _newMessage,
                  displayEmojis: _emojiShowing,
                  focusNode: _focusNode,
                  onEmojiTap: () {
                    {
                      setState(() => _emojiShowing = !_emojiShowing);
                      dismissKeyboard();
                    }
                  },
                ),
              ),
              MessagingEmojiPicker(
                showEmojis: _emojiShowing,
                emptySuggestions: 'No Recents'.i18n,
                height: size!.height * 0.25,
                onBackspacePressed: () {
                  _newMessage
                    ..text = _newMessage.text.characters.skipLast(1).toString()
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: _newMessage.text.length));
                },
                onEmojiSelected: (category, emoji) async {
                  if (_customEmojiResponse && _storedMessage != null) {
                    dismissKeyboard();
                    await model.react(_storedMessage!, emoji.emoji);
                    _storedMessage = null;
                  }
                  setState(() => _isSendIconVisible = true);
                  _newMessage
                    ..text += emoji.emoji
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: _newMessage.text.length));
                },
              ),
            ],
          ),
        ]));
  }

  Widget _buildMessagesLifeExpectancy() => model.singleContact(
        context,
        widget._contact,
        (context, contact, child) => ListTile(
          dense: true,
          minLeadingWidth: 18,
          leading: contact.messagesDisappearAfterSeconds > 0
              ? const Icon(Icons.timer, size: 18)
              : const Icon(Icons.lock_clock, size: 18),
          title: contact.messagesDisappearAfterSeconds > 0
              ? Text(
                  'Messages disappear after ${contact.messagesDisappearAfterSeconds.humanizeSeconds(longForm: true)}',
                  style: const TextStyle(fontSize: 13),
                )
              : const Text('New messages do not disappear',
                  style: TextStyle(fontSize: 13)),
        ),
      );

  Widget _buildMessageBubbles() {
    return model.contactMessages(widget._contact, builder: (context,
        Iterable<PathAndValue<StoredMessage>> messageRecords, Widget? child) {
      // interesting discussion on ScrollablePositionedList over ListView https://stackoverflow.com/a/58924218
      return messageRecords.isEmpty
          ? Container()
          : ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              reverse: true,
              itemCount: messageRecords.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: messageRecords.elementAt(index),
                  priorMessage: index >= messageRecords.length - 1
                      ? null
                      : messageRecords.elementAt(index + 1).value,
                  nextMessage: index == 0
                      ? null
                      : messageRecords.elementAt(index - 1).value,
                  contact: widget._contact,
                  onEmojiTap: (showEmoji, messageSelected) => setState(() {
                    _emojiShowing = true;
                    _customEmojiResponse = true;
                    _storedMessage = messageSelected;
                  }),
                  onReply: (_message) {
                    setState(() {
                      _isReplying = true;
                      _quotedMessage = _message;
                      showKeyboard();
                    });
                  },
                  onTapReply: (_tappedMessage) {
                    final _scrollToIndex = messageRecords.toList().indexWhere(
                        (element) =>
                            element.value.id == _tappedMessage.value.replyToId);
                    if (_scrollToIndex != -1) {
                      _scrollController.scrollTo(
                          index: _scrollToIndex,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOutCubic);
                    }
                  },
                );
              },
            );
    });
  }
}

typedef ShowEmojis = void Function(
    bool showEmoji, PathAndValue<StoredMessage>? messageStored);

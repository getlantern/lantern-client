import 'dart:typed_data';
import 'dart:ui';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/voice_recorder.dart';
import 'package:lantern/messaging/widgets/disappearing_timer_action.dart';
import 'package:lantern/messaging/widgets/message_bubble.dart';
import 'package:lantern/messaging/widgets/staging_container_item.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/model/tab_status.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class Conversation extends StatefulWidget {
  final Contact _contact;

  Conversation(this._contact) : super();

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation>
    with WidgetsBindingObserver {
  late MessagingModel model;

  final TextEditingController _newMessage = TextEditingController();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool _recording = false;
  bool _willCancelRecording = false;
  double _totalPanned = 0.0;
  bool _isSendIconVisible = false;
  bool _isReplying = false;
  StoredMessage? _quotedMessage;
  var displayName = '';
  bool _emojiShowing = false;
  final _focusNode = FocusNode();
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
      setState(() {
        _emojiShowing = false;
      });
      return true;
    } else {
      return false;
    }
  }

  void _send(String text,
      {List<Uint8List>? attachments,
      String? replyToSenderId,
      String? replyToId}) {
    model.sendToDirectContact(
      widget._contact.contactId.id,
      text: text,
      attachments: attachments,
      replyToId: replyToId,
      replyToSenderId: replyToSenderId,
    );
    dismissKeyboard();
    _newMessage.clear();
    setState(() {
      _quotedMessage = null;
    });
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
        _send(_newMessage.value.text, attachments: [attachment]);
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

  void showKeyboard() {
    _focusNode.requestFocus();
  }

  void dismissKeyboard() {
    _focusNode.unfocus();
  }

  void _handleSubmit(TextEditingController _newMessage) {
    setState(() {
      _isSendIconVisible = false;
      _isReplying = false;
      _emojiShowing = false;
    });
    _send(_newMessage.value.text,
        replyToSenderId: _quotedMessage?.senderId,
        replyToId: _quotedMessage?.id);
    dismissKeyboard();
  }

  @override
  Widget build(BuildContext context) {
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
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
        // Conversation body
        child: Stack(children: [
          Column(children: [
            // Conversation subtitle
            Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: _buildMessagesLifeExpectancy()),
            // Message bubbles
            Expanded(
              child: _buildMessageBubbles(),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Divider(height: 3),
            ),
            // Message bar
            if (_isReplying)
              Padding(
                padding: const EdgeInsets.all(8),
                child: StagingContainerItem(
                    quotedMessage: _quotedMessage,
                    model: model,
                    contact: widget._contact,
                    onCloseListener: () => setState(() {
                          _isReplying = false;
                        })),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildMessageBar(context),
            ),
            if (_emojiShowing) _buildEmojiKeyboard(),
          ]),
          // Voice recorder
          if (_recording)
            VoiceRecorder(
              stopWatchTimer: _stopWatchTimer,
              willCancelRecording: _willCancelRecording,
              onTapUpListener: () async {
                await _finishRecording();
              },
            ),
        ]),
      ),
    );
  }

  Widget _buildMessagesLifeExpectancy() {
    return model.singleContact(
        context,
        widget._contact,
        (context, contact, child) => contact.messagesDisappearAfterSeconds > 0
            ? Text(
                'New messages disappear after ${contact.messagesDisappearAfterSeconds.humanizeSeconds(longForm: true)}')
            : Container());
  }

  Widget _buildMessageBubbles() {
    return model.contactMessages(widget._contact, builder: (context,
        Iterable<PathAndValue<StoredMessage>> messageRecords, Widget? child) {
      // interesting discussion on ScrollablePositionedList over ListView https://stackoverflow.com/a/58924218
      return ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        reverse: true,
        itemCount: messageRecords.length,
        itemBuilder: (context, index) {
          return MessageBubble(
            message: messageRecords.elementAt(index),
            priorMessage: index >= messageRecords.length - 1
                ? null
                : messageRecords.elementAt(index + 1).value,
            nextMessage:
                index == 0 ? null : messageRecords.elementAt(index - 1).value,
            contact: widget._contact,
            onReply: (_message) {
              setState(() {
                _isReplying = true;
                _quotedMessage = _message;
                showKeyboard(); // TODO: this is clashing with Navigator.pop(context);
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

  Widget _buildMessageBar(context) {
    return Row(children: [
      Container(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              _emojiShowing = !_emojiShowing;
            });
            dismissKeyboard();
          },
          child: const Icon(Icons.insert_emoticon),
        ),
      ),
      Expanded(
        // Text field
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextFormField(
            autofocus: false,
            focusNode: _focusNode,
            textInputAction: TextInputAction.send,
            controller: _newMessage,
            onTap: () => setState(() {
              _emojiShowing = false;
            }),
            onChanged: (value) {
              setState(() {
                _isSendIconVisible = value.isNotEmpty;
              });
            },
            //
            onFieldSubmitted: (value) => _handleSubmit(_newMessage),
            decoration: InputDecoration(
              // Send icon
              suffixIcon: _isSendIconVisible
                  ? IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: () => _handleSubmit(_newMessage))
                  : null,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Message'.i18n,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ),
      // Attachments icon
      if (!_isSendIconVisible)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _selectFilesToShare(),
            child: const Icon(Icons.add_circle_rounded),
          ),
        ),
      if (!_isSendIconVisible)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              _startRecording();
            },
            onTapUp: (details) async {
              await _finishRecording();
            },
            child: const Icon(Icons.mic),
          ),
        ),
    ]);
  }

  Offstage _buildEmojiKeyboard() {
    // https://github.com/Fintasys/emoji_picker_flutter
    return Offstage(
      offstage: !_emojiShowing,
      child: Container(
        height: 200,
        child: EmojiPicker(
            onEmojiSelected: (Category category, Emoji emoji) {
              setState(() {
                _isSendIconVisible = true;
              });
              _newMessage
                ..text += emoji.emoji
                ..selection = TextSelection.fromPosition(
                    TextPosition(offset: _newMessage.text.length));
            },
            onBackspacePressed: () {
              _newMessage
                ..text = _newMessage.text.characters.skipLast(1).toString()
                ..selection = TextSelection.fromPosition(
                    TextPosition(offset: _newMessage.text.length));
            },
            config: const Config(
              columns: 10,
              emojiSizeMax: 17.0,
              verticalSpacing: 0,
              horizontalSpacing: 0,
              initCategory: Category.SMILEYS,
              bgColor: Color(0xFFF2F2F2),
              // TODO: generalize in theme
              indicatorColor: Colors.black,
              // TODO: generalize in theme
              iconColor: Colors.grey,
              iconColorSelected: Colors.black,
              // TODO: generalize in theme
              progressIndicatorColor: Colors.black,
              // TODO: generalize in theme
              backspaceColor: Colors.black,
              // TODO: generalize in theme
              showRecentsTab: true,
              recentsLimit: 28,
              noRecentsText: 'No Recents',
              noRecentsStyle: TextStyle(fontSize: 16, color: Colors.black26),
              // TODO: generalize in theme
              categoryIcons: CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL,
            )),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:lantern/core/router/router.gr.dart' as router_gr;
import 'package:lantern/messaging/conversation/audio/audio_widget.dart';
import 'package:lantern/messaging/conversation/audio/message_bar_preview_recording.dart';
import 'package:lantern/messaging/conversation/audio/voice_recorder.dart';
import 'package:lantern/messaging/conversation/conversation_sticker.dart';
import 'package:lantern/messaging/conversation/disappearing_timer_action.dart';
import 'package:lantern/messaging/conversation/message_bubble.dart';
import 'package:lantern/messaging/conversation/messaging_emoji_picker.dart';
import 'package:lantern/messaging/conversation/pulsating_indicator.dart';
import 'package:lantern/messaging/conversation/replies/reply_preview.dart';
import 'package:lantern/messaging/conversation/stopwatch_timer.dart';
import 'package:lantern/messaging/messaging.dart';

import 'call_action.dart';

class Conversation extends StatefulWidget {
  final ContactId _contactId;

  Conversation(this._contactId) : super();

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation>
    with WidgetsBindingObserver {
  late MessagingModel model;
  late final ShowEmojis onEmojiTap;
  bool _customEmojiResponse = false;
  bool _hasPermission = false;

  final TextEditingController _newMessage = TextEditingController();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool _isRecording = false;
  bool _finishedRecording = false;
  bool _isSendIconVisible = false;
  bool _isReplying = false;
  Uint8List? _recording;
  AudioController? _audioPreviewController;
  StoredMessage? _quotedMessage;
  var messageCount = 0;
  PathAndValue<StoredMessage>? _storedMessage;
  final _scrollController = ItemScrollController();

  // ********************** Keyboard Handling ***************************/
  final keyboardVisibilityController = KeyboardVisibilityController();
  StreamSubscription<bool>? keyboardSubscription;
  final focusNode = FocusNode();
  var nativeKeyboardShown = false;
  var emojiKeyboardRequested = false;
  var emojiKeyboardShown = false;
  static var mostRecentKeyboardHeight = 0.0;

  void showNativeKeyboard() {
    setState(() {
      nativeKeyboardShown = true;
    });
    focusNode.requestFocus();
  }

  void dismissNativeKeyboard() {
    focusNode.unfocus();
  }

  void showEmojiKeyboard() {
    if (mostRecentKeyboardHeight > 0) {
      // We've shown the native keyboard before and know the height, show emoji
      // keyboard immediately.
      setState(() {
        nativeKeyboardShown = false;
        emojiKeyboardShown = true;
      });
      dismissNativeKeyboard();
      return;
    }

    // We haven't shown the keyboard yet so don't know how high to make the
    // emoji keyboard. Display the native keyboard first and then the emoji
    // keyboard.
    emojiKeyboardRequested = true;
    showNativeKeyboard();
  }

  void subscribeToKeyboardChanges() {
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      // run after some small delay to make sure insets show up correctly
      Future.delayed(const Duration(milliseconds: 5), () {
        if (visible) {
          mostRecentKeyboardHeight = max(
              EdgeInsets.fromWindowPadding(
                      WidgetsBinding.instance!.window.viewInsets,
                      WidgetsBinding.instance!.window.devicePixelRatio)
                  .bottom,
              MediaQuery.of(context).viewInsets.bottom);
        }

        if (visible && emojiKeyboardRequested) {
          // native keyboard was shown but we want the emoji keyboard, show it
          setState(() {
            emojiKeyboardShown = true;
            nativeKeyboardShown = false;
            emojiKeyboardRequested = false;
          });
          dismissNativeKeyboard();
        } else {
          // call setState to pick up latest keyboard height from KeyboardHelper
          setState(() {
            nativeKeyboardShown = visible;
          });
        }
      });
    });
  }

  void dismissAllKeyboards() {
    dismissNativeKeyboard();
    setState(() {
      nativeKeyboardShown = false;
      emojiKeyboardShown = false;
    });
  }

  Widget dismissKeyboardsOnTap(Widget child) {
    return GestureDetector(
      onTap: dismissAllKeyboards,
      child: child,
    );
  }

  bool _interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
    if (emojiKeyboardShown) {
      setState(() {
        emojiKeyboardShown = false;
        emojiKeyboardRequested = false;
      });
      return true;
    } else {
      return false;
    }
  }

  // ******************* End Keyboard Handling **************************

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
        model.setCurrentConversationContact(widget._contactId.id);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    BackButtonInterceptor.add(_interceptBackButton);
    subscribeToKeyboardChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _newMessage.dispose();
    _stopWatchTimer.dispose();
    focusNode.dispose();
    _audioPreviewController?.stop();
    keyboardSubscription?.cancel();
    BackButtonInterceptor.remove(_interceptBackButton);
    super.dispose();
  }

  Future<void> _send(String text,
      {List<Uint8List>? attachments,
      String? replyToSenderId,
      String? replyToId}) async {
    if (attachments?.isNotEmpty == true) context.loaderOverlay.show();
    try {
      await model.sendToDirectContact(
        widget._contactId.id,
        text: text,
        attachments: attachments,
        replyToId: replyToId,
        replyToSenderId: replyToSenderId,
      );
      _newMessage.clear();
      setState(() {
        _recording = null;
        _audioPreviewController = null;
      });
      if (messageCount > 0) {
        await _scrollController.scrollTo(
            index: 00,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOutCubic);
      }
    } catch (e, s) {
      showErrorDialog(context, e: e, s: s, des: 'send_error'.i18n);
    } finally {
      if (attachments?.isNotEmpty == true) context.loaderOverlay.hide();
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) {
      return;
    }
    _hasPermission = await model.startRecordingVoiceMemo();
    if (_hasPermission) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _finishRecording() async {
    if (!_isRecording) {
      return;
    }

    context.loaderOverlay.show();
    try {
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      _recording = await model.stopRecordingVoiceMemo();
      var attachment = StoredAttachment.fromBuffer(_recording!);
      setState(() {
        _isRecording = false;
        _finishedRecording = true;
        _audioPreviewController =
            AudioController(context: context, attachment: attachment);
      });
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> _selectFilesToShare() async {
    try {
      var result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);
      if (result == null || result.files.isEmpty) {
        // user didn't pick any files, don't share anything
        return;
      }
      context.loaderOverlay.show();
      result.files.forEach((el) async {
        // TODO: we might need to sanitize title
        final title = el.path.toString().split('file_picker/')[1].split('.')[
            0]; // example path: /data/user/0/org.getlantern.lantern/cache/file_picker/alpha_png.png
        final fileExtension =
            el.path.toString().split('file_picker/')[1].split('.')[1];
        final metadata = {
          'title': title,
          'fileExtension': fileExtension,
        };
        final attachment =
            await model.filePickerLoadAttachment(el.path.toString(), metadata);
        await _send(_newMessage.value.text, attachments: [attachment]);
      });
    } catch (e, s) {
      showErrorDialog(context, e: e, s: s, des: 'share_media_error'.i18n);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> _handleSubmit(TextEditingController _newMessage) async {
    if (mounted) {
      setState(() {
        _isSendIconVisible = false;
        _isReplying = false;
      });
    }
    await _send(_newMessage.value.text,
        replyToSenderId: _quotedMessage?.senderId,
        replyToId: _quotedMessage?.id);
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    (context.router.currentChild!.name == router_gr.Conversation.name)
        ? unawaited(model.setCurrentConversationContact(widget._contactId.id))
        : unawaited(model.clearCurrentConversationContact());
    return model.singleContactById(context, widget._contactId,
        (context, contact, child) {
      final title = contact.displayName.isNotEmpty
          ? contact.displayName
          : contact.contactId.id;
      return BaseScreen(
        resizeToAvoidBottomInset: false,
        centerTitle: false,
        // Conversation title (contact name)
        title: dismissKeyboardsOnTap(
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomAvatar(
                  id: contact.contactId.id, displayName: contact.displayName),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextOneLine(
                      title,
                      style: tsTitleAppbar,
                    ),
                    DisappearingTimerAction(contact),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CallAction(contact),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                tooltip: 'menu'.i18n,
                onPressed: () =>
                    displayConversationOptions(model, context, contact),
              )
            ],
          ),
        ],
        body: Padding(
          padding: EdgeInsetsDirectional.only(
              bottom: nativeKeyboardShown && !emojiKeyboardShown
                  ? mostRecentKeyboardHeight
                  : 0),
          child: Stack(children: [
            Column(
              children: [
                dismissKeyboardsOnTap(
                  Card(
                    color: grey1,
                    child: _buildConversationSticker(contact),
                  ),
                ),
                Flexible(
                  child: dismissKeyboardsOnTap(_buildMessageBubbles(contact)),
                ),
                // Reply container
                if (_isReplying)
                  ReplyPreview(
                    quotedMessage: _quotedMessage,
                    model: model,
                    contact: contact,
                    onCloseListener: () => setState(() => _isReplying = false),
                  ),
                Divider(height: 1.0, color: grey3),
                Container(
                  color: _isRecording
                      ? const Color.fromRGBO(245, 245, 245, 1)
                      : Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: kBottomNavigationBarHeight,
                  child: _buildMessageBar(),
                ),
                Offstage(
                  offstage: !emojiKeyboardShown,
                  child: MessagingEmojiPicker(
                    height: mostRecentKeyboardHeight,
                    emptySuggestions: 'no_recents'.i18n,
                    onBackspacePressed: () {
                      _newMessage
                        ..text =
                            _newMessage.text.characters.skipLast(1).toString()
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: _newMessage.text.length));
                    },
                    onEmojiSelected: (category, emoji) async {
                      if (mounted &&
                          _customEmojiResponse &&
                          _storedMessage != null) {
                        await model.react(_storedMessage!, emoji.emoji);
                        _storedMessage = null;
                        dismissAllKeyboards();
                      } else {
                        setState(() => _isSendIconVisible = true);
                        _newMessage
                          ..text += emoji.emoji
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _newMessage.text.length));
                      }
                    },
                  ),
                ),
              ],
            ),
          ]),
        ),
      );
    });
  }

  Widget _buildConversationSticker(Contact contact) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth * 0.7,
            child: model.introductionsToContact(
              builder: (context,
                  Iterable<PathAndValue<StoredMessage>> introductions,
                  Widget? child) {
                final isPendingIntroduction = !contact.hasReceivedMessage &&
                    introductions
                        .toList()
                        .where((intro) =>
                            intro.value.introduction.to == contact.contactId)
                        .isNotEmpty;
                return ConversationSticker(
                    contact: contact,
                    isPendingIntroduction: isPendingIntroduction);
              },
            ),
          );
        },
      );

  Widget _buildMessageBubbles(Contact contact) {
    return model.contactMessages(contact, builder: (context,
        Iterable<PathAndValue<StoredMessage>> messageRecords, Widget? child) {
      // interesting discussion on ScrollablePositionedList over ListView https://stackoverflow.com/a/58924218
      messageCount = messageRecords.length;
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
                  contact: contact,
                  onEmojiTap: (showEmoji, messageSelected) => setState(() {
                    setState(() {
                      _customEmojiResponse = true;
                      _storedMessage = messageSelected;
                    });
                    showEmojiKeyboard();
                  }),
                  onReply: (_message) {
                    setState(() {
                      _isReplying = true;
                      _quotedMessage = _message;
                      showNativeKeyboard();
                    });
                  },
                  onTapReply: (_tappedMessage) {
                    final _scrollToIndex = messageRecords.toList().indexWhere(
                        (element) =>
                            element.value.id == _tappedMessage.value.replyToId);
                    if (_scrollToIndex != -1 && _scrollController.isAttached) {
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

  Widget _buildMessageBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin: _isRecording
          ? const EdgeInsets.only(right: 0, left: 8.0, bottom: 0)
          : EdgeInsets.zero,
      child: IndexedStack(
        index: _finishedRecording ? 1 : 0,
        children: [
          _buildMessageBarRecording(context),
          _audioPreviewController == null
              ? const SizedBox()
              : MessageBarPreviewRecording(
                  model: model,
                  audioController: _audioPreviewController!,
                  onCancelRecording: () async => setState(() {
                    _isRecording = false;
                    _finishedRecording = false;
                    _recording = null;
                    _audioPreviewController = null;
                  }),
                  onSend: () {
                    _audioPreviewController!.audio.stop();
                    send();
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMessageBarRecording(BuildContext context) {
    return ListTile(
      contentPadding: _isRecording
          ? const EdgeInsets.only(right: 0, left: 2.0)
          : EdgeInsets.zero,
      leading: _isRecording
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: PulsatingIndicator(
                    width: 25,
                    height: 25,
                    duration: const Duration(milliseconds: 700),
                    pulseColor: stopwatchColor,
                    color: pulsingBackground,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: StopwatchTimer(
                      stopWatchTimer: _stopWatchTimer,
                      style: tsStopWatchTimer,
                    ),
                  ),
                ),
              ],
            )
          : IconButton(
              onPressed: () {
                {
                  setState(() {
                    if (!emojiKeyboardShown || nativeKeyboardShown) {
                      showEmojiKeyboard();
                    } else {
                      showNativeKeyboard();
                    }
                  });
                }
              },
              icon: Icon(Icons.sentiment_very_satisfied,
                  color: !emojiKeyboardShown
                      ? Theme.of(context).primaryIconTheme.color
                      : Theme.of(context).primaryColorDark),
            ),
      title: Stack(
        alignment: Alignment.center,
        children: [
          TextFormField(
            autofocus: false,
            textInputAction: TextInputAction.send,
            controller: _newMessage,
            onChanged: (value) =>
                setState(() => _isSendIconVisible = value.isNotEmpty),
            focusNode: focusNode,
            onFieldSubmitted: (value) async =>
                value.isEmpty ? null : await _handleSubmit(_newMessage),
            decoration: InputDecoration(
              // Send icon
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'message'.i18n,
              border: const OutlineInputBorder(),
            ),
          ),
          // hide TextFormField while recording by painting over it. this allows
          // the form field to retain focus to keep the keyboard open and keep
          // the layout from changing while we're recording.
          if (_isRecording)
            SizedBox(
              child: Container(
                decoration: BoxDecoration(color: grey2),
              ),
            ),
        ],
      ),
      trailing: _isSendIconVisible && !_isRecording
          ? IconButton(
              key: const ValueKey('send_message'),
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: send,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _isRecording
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () async => await _selectFilesToShare(),
                        icon: const Icon(Icons.add_circle_rounded),
                      ),
                VoiceRecorder(
                  isRecording: _isRecording,
                  onRecording: () async => await _startRecording(),
                  onStopRecording: () async =>
                      _hasPermission ? await _finishRecording() : null,
                  onTapUpListener: () async => await _finishRecording(),
                ),
              ],
            ),
    );
  }

  void send() async {
    if (_newMessage.value.text.trim().isEmpty && _recording == null) {
      return;
    }
    await _send(_newMessage.value.text,
        attachments:
            _recording != null && _recording!.isNotEmpty ? [_recording!] : [],
        replyToSenderId: _quotedMessage?.senderId,
        replyToId: _quotedMessage?.id);
    if (mounted) {
      setState(() {
        _quotedMessage = null;
        _isRecording = false;
        _finishedRecording = false;
        _isSendIconVisible = false;
        _isReplying = false;
      });
    }
  }
}

typedef ShowEmojis = void Function(
    bool showEmoji, PathAndValue<StoredMessage>? messageStored);

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
import 'show_conversation_options.dart';

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
  bool _reactingWithEmoji = false;
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
  var keyboardMode = KeyboardMode.none;

  // default the below to reasonable value, it will get updated when the
  // keyboard displays
  double get defaultKeyboardHeight => MediaQuery.of(context).size.height * 0.4;
  static var highestKeyboardHeight = 0.0;

  void showNativeKeyboard() {
    focusNode.requestFocus();
  }

  void dismissNativeKeyboard() {
    focusNode.unfocus();
  }

  void showEmojiKeyboard(bool reaction) {
    // always show native keyboard first so we know the height of the native
    // keyboard and can make the emoji keyboard the same height
    setState(() {
      keyboardMode = reaction ? KeyboardMode.emojiReaction : KeyboardMode.emoji;
    });
    dismissNativeKeyboard();
  }

  void updateKeyboardHeight() {
    var currentKeyboardHeight = max(
        EdgeInsets.fromWindowPadding(WidgetsBinding.instance!.window.viewInsets,
                WidgetsBinding.instance!.window.devicePixelRatio)
            .bottom,
        MediaQuery.of(context).viewInsets.bottom);
    if (currentKeyboardHeight > highestKeyboardHeight) {
      setState(() {
        highestKeyboardHeight = currentKeyboardHeight;
      });
    }
  }

  void subscribeToKeyboardChanges() {
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      updateKeyboardHeight();
      if (visible) {
        if (keyboardMode == KeyboardMode.emojiReaction) {
          dismissNativeKeyboard();
        } else {
          setState(() {
            keyboardMode = KeyboardMode.native;
          });
        }
      } else if (keyboardMode == KeyboardMode.native) {
        setState(() {
          keyboardMode = KeyboardMode.none;
        });
      }
    });
  }

  void dismissAllKeyboards() {
    dismissNativeKeyboard();
    setState(() {
      keyboardMode = KeyboardMode.none;
    });
  }

  Widget dismissKeyboardsOnTap(Widget child) {
    return GestureDetector(
      onTap: dismissAllKeyboards,
      child: child,
    );
  }

  bool _interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
    if (keyboardMode == KeyboardMode.emoji) {
      setState(() {
        keyboardMode = KeyboardMode.none;
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

    // update keyboard height values
    updateKeyboardHeight();

    final keyboardHeight = highestKeyboardHeight > 0
        ? highestKeyboardHeight
        : defaultKeyboardHeight;

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
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: CustomAvatar(
                    id: contact.contactId.id, displayName: contact.displayName),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CText(
                      title,
                      maxLines: 1,
                      style: tsHeading3,
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
                padding:
                    const EdgeInsetsDirectional.only(top: 8, bottom: 8, end: 8),
                tooltip: 'menu'.i18n,
                onPressed: () => showConversationOptions(
                    model: model, parentContext: context, contact: contact),
              )
            ],
          ),
        ],
        body: Padding(
          padding: EdgeInsetsDirectional.only(
              bottom:
                  keyboardMode == KeyboardMode.native ? keyboardHeight : 0.0),
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
                  offstage: keyboardMode != KeyboardMode.emoji &&
                      keyboardMode != KeyboardMode.emojiReaction,
                  child: MessagingEmojiPicker(
                    height: keyboardHeight,
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
                          _reactingWithEmoji &&
                          _storedMessage != null) {
                        await model.react(_storedMessage!, emoji.emoji);
                        _reactingWithEmoji = false;
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
                      _reactingWithEmoji = true;
                      _storedMessage = messageSelected;
                    });
                    showEmojiKeyboard(true);
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
                    pulseColor: indicatorRed,
                    color: indicatorRed,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: StopwatchTimer(
                      stopWatchTimer: _stopWatchTimer,
                      style: tsOverline.copiedWith(color: indicatorRed),
                    ),
                  ),
                ),
              ],
            )
          : IconButton(
              onPressed: () {
                {
                  if (keyboardMode == KeyboardMode.emoji ||
                      keyboardMode == KeyboardMode.emojiReaction) {
                    keyboardMode = KeyboardMode.native;
                    showNativeKeyboard();
                  } else {
                    showEmojiKeyboard(false);
                  }
                }
              },
              icon: Icon(
                  keyboardMode == KeyboardMode.emoji ||
                          keyboardMode == KeyboardMode.emojiReaction
                      ? Icons.keyboard_alt_outlined
                      : Icons.sentiment_very_satisfied,
                  color: grey5),
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

enum KeyboardMode { none, native, emoji, emojiReaction }

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:lantern/core/router/router.gr.dart' as router_gr;
import 'package:lantern/messaging/conversation/audio/audio_widget.dart';
import 'package:lantern/messaging/conversation/audio/message_bar_preview_recording.dart';
import 'package:lantern/messaging/conversation/conversation_sticker.dart';
import 'package:lantern/messaging/conversation/disappearing_timer_action.dart';
import 'package:lantern/messaging/conversation/message_bubble.dart';
import 'package:lantern/messaging/conversation/messaging_emoji_picker.dart';
import 'package:lantern/messaging/conversation/pulsating_indicator.dart';
import 'package:lantern/messaging/conversation/replies/reply_preview.dart';
import 'package:lantern/messaging/conversation/stopwatch_timer.dart';
import 'package:lantern/messaging/messaging.dart';

import 'audio/voice_recorder.dart';
import 'call_action.dart';
import 'date_marker_bubble.dart';
import 'show_conversation_options.dart';

class Conversation extends StatefulWidget {
  final ContactId contactId;

  Conversation(this.contactId) : super();

  @override
  ConversationState createState() => ConversationState();
}

class ConversationState extends State<Conversation>
    with WidgetsBindingObserver {
  static final dayFormat = DateFormat.yMMMMd();

  late MessagingModel model;
  bool reactingWithEmoji = false;
  bool hasPermission = false;

  final TextEditingController newMessage = TextEditingController();
  final StopWatchTimer stopWatchTimer = StopWatchTimer();
  bool isRecording = false;
  bool finishedRecording = false;
  bool isSendIconVisible = false;
  bool isReplying = false;
  Uint8List? recording;
  AudioController? audioPreviewController;
  StoredMessage? quotedMessage;
  var messageCount = 0;
  PathAndValue<StoredMessage>? storedMessage;
  final scrollController = ItemScrollController();

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

  bool interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
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
        model.setCurrentConversationContact(widget.contactId.id);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    BackButtonInterceptor.add(interceptBackButton);
    subscribeToKeyboardChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    newMessage.dispose();
    stopWatchTimer.dispose();
    focusNode.dispose();
    audioPreviewController?.stop();
    keyboardSubscription?.cancel();
    BackButtonInterceptor.remove(interceptBackButton);
    super.dispose();
  }

  Future<void> sendMessage(String text,
      {List<Uint8List>? attachments,
      String? replyToSenderId,
      String? replyToId}) async {
    if (attachments?.isNotEmpty == true) context.loaderOverlay.show();
    try {
      await model.sendToDirectContact(
        widget.contactId.id,
        text: text,
        attachments: attachments,
        replyToId: replyToId,
        replyToSenderId: replyToSenderId,
      );
      newMessage.clear();
      setState(() {
        recording = null;
        audioPreviewController = null;
      });
      if (messageCount > 0) {
        await scrollController.scrollTo(
            index: 0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOutCubic);
      }
    } catch (e, s) {
      showErrorDialog(context, e: e, s: s, des: 'send_error'.i18n);
    } finally {
      if (attachments?.isNotEmpty == true) context.loaderOverlay.hide();
    }
  }

  Future<void> startRecording() async {
    if (isRecording) {
      return;
    }
    hasPermission = await model.startRecordingVoiceMemo();
    if (hasPermission) {
      stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      stopWatchTimer.onExecute.add(StopWatchExecute.start);
      setState(() {
        isRecording = true;
      });
    }
  }

  Future<void> finishRecording() async {
    if (!isRecording) {
      return;
    }

    context.loaderOverlay.show();
    try {
      stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      recording = await model.stopRecordingVoiceMemo();
      var attachment = StoredAttachment.fromBuffer(recording!);
      setState(() {
        isRecording = false;
        finishedRecording = true;
        audioPreviewController =
            AudioController(context: context, attachment: attachment);
      });
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> selectFilesToShare() async {
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
        await sendMessage(newMessage.value.text, attachments: [attachment]);
      });
    } catch (e, s) {
      showErrorDialog(context, e: e, s: s, des: 'share_media_error'.i18n);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> handleSubmit(TextEditingController newMessage) async {
    if (mounted) {
      setState(() {
        isSendIconVisible = false;
        isReplying = false;
      });
    }
    await sendMessage(newMessage.value.text,
        replyToSenderId: quotedMessage?.senderId, replyToId: quotedMessage?.id);
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
        ? unawaited(model.setCurrentConversationContact(widget.contactId.id))
        : unawaited(model.clearCurrentConversationContact());
    return model.singleContactById(context, widget.contactId,
        (context, contact, child) {
      final title = contact.displayName.isNotEmpty
          ? contact.displayName
          : contact.contactId.id;
      return BaseScreen(
        resizeToAvoidBottomInset: false,
        centerTitle: false,
        padHorizontal: false,
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
                Flexible(
                  child: dismissKeyboardsOnTap(
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: buildList(contact),
                    ),
                  ),
                ),
                // Reply container
                if (isReplying)
                  ReplyPreview(
                    quotedMessage: quotedMessage,
                    model: model,
                    contact: contact,
                    onCloseListener: () => setState(() => isReplying = false),
                  ),
                Divider(height: 1.0, color: grey3),
                Container(
                  color: isRecording ? grey2 : white,
                  width: MediaQuery.of(context).size.width,
                  height: messageBarHeight,
                  child: buildMessageBar(),
                ),
                Offstage(
                  offstage: keyboardMode != KeyboardMode.emoji &&
                      keyboardMode != KeyboardMode.emojiReaction,
                  child: MessagingEmojiPicker(
                    height: keyboardHeight,
                    emptySuggestions: 'no_recents'.i18n,
                    onBackspacePressed: () {
                      newMessage
                        ..text =
                            newMessage.text.characters.skipLast(1).toString()
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: newMessage.text.length));
                    },
                    onEmojiSelected: (category, emoji) async {
                      if (mounted &&
                          reactingWithEmoji &&
                          storedMessage != null) {
                        await model.react(storedMessage!.value, emoji.emoji);
                        reactingWithEmoji = false;
                        storedMessage = null;
                        dismissAllKeyboards();
                      } else {
                        setState(() => isSendIconVisible = true);
                        newMessage
                          ..text += emoji.emoji
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: newMessage.text.length));
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

  Widget buildConversationSticker(Contact contact) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Card(
            color: grey1,
            child: Container(
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
            ),
          );
        },
      );

  Widget buildList(Contact contact) {
    return model.contactMessages(contact, builder: (context,
        Iterable<PathAndValue<StoredMessage>> originalMessageRecords,
        Widget? child) {
      // Build list that includes original message records as well as date
      // separators.
      var listItems = <Object>[];
      String? priorDate;
      originalMessageRecords.forEach((messageRecord) {
        final date = dayFormat.format(DateTime.fromMillisecondsSinceEpoch(
            messageRecord.value.ts.toInt()));
        if (priorDate != null && date != priorDate) {
          listItems.add(date);
        }
        priorDate = date;
        listItems.add(messageRecord);
      });

      // render list
      messageCount = listItems.length;
      if (listItems.isEmpty) {
        return Container();
      }

      // interesting discussion on ScrollablePositionedList over ListView https://stackoverflow.com/a/58924218
      return ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        reverse: true,
        itemCount: listItems.length + 1,
        itemBuilder: (context, index) {
          if (index == listItems.length) {
            // show sticker as first item
            return buildConversationSticker(contact);
          }

          final item = listItems[index];
          if (item is PathAndValue<StoredMessage>) {
            return buildMessageBubble(context, contact, listItems, item, index);
          } else {
            return DateMarker(item as String);
          }
        },
      );
    });
  }

  Widget buildMessageBubble(
      BuildContext context,
      Contact contact,
      List<Object> listItems,
      PathAndValue<StoredMessage> messageAndPath,
      int index) {
    return model.message(context, messageAndPath,
        (BuildContext context, StoredMessage message, Widget? child) {
      return MessageBubble(
        message: message,
        priorMessage: priorMessage(listItems, index)?.value,
        nextMessage: nextMessage(listItems, index)?.value,
        contact: contact,
        onEmojiTap: () {
          setState(() {
            reactingWithEmoji = true;
            storedMessage = messageAndPath;
          });
          showEmojiKeyboard(true);
        },
        onReply: () {
          setState(() {
            isReplying = true;
            quotedMessage = message;
            showNativeKeyboard();
          });
        },
        onTapReply: () {
          final scrollToIndex = listItems.toList().indexWhere((element) =>
              element is PathAndValue<StoredMessage> &&
              element.value.id == message.replyToId);
          if (scrollToIndex != -1 && scrollController.isAttached) {
            scrollController.scrollTo(
                index: scrollToIndex,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOutCubic);
          }
        },
      );
    });
  }

  PathAndValue<StoredMessage>? priorMessage(List<Object> listItems, int index) {
    for (var i = index + 1; i < listItems.length; i++) {
      final candidate = listItems[i];
      if (candidate is PathAndValue<StoredMessage>) {
        return candidate;
      }
    }
    return null;
  }

  PathAndValue<StoredMessage>? nextMessage(List<Object> listItems, int index) {
    for (var i = index - 1; i >= 0; i--) {
      final candidate = listItems[i];
      if (candidate is PathAndValue<StoredMessage>) {
        return candidate;
      }
    }
    return null;
  }

  Widget buildMessageBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: IndexedStack(
        index: finishedRecording ? 1 : 0,
        children: [
          buildMessageBarRecording(context),
          audioPreviewController == null
              ? const SizedBox()
              : MessageBarPreviewRecording(
                  model: model,
                  audioController: audioPreviewController!,
                  onCancelRecording: () async => setState(() {
                    isRecording = false;
                    finishedRecording = false;
                    recording = null;
                    audioPreviewController = null;
                  }),
                  onSend: () {
                    audioPreviewController!.audio.stop();
                    send();
                  },
                ),
        ],
      ),
    );
  }

  Widget buildMessageBarRecording(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CListTile(
          height: messageBarHeight,
          endPadding: 48,
          showDivider: false,
          leading: isRecording
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: PulsatingIndicator(
                          width: 25,
                          height: 25,
                          duration: const Duration(milliseconds: 700),
                          pulseColor: indicatorRed,
                          color: indicatorRed,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: StopwatchTimer(
                          stopWatchTimer: stopWatchTimer,
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
          content: Stack(
            alignment: Alignment.center,
            children: [
              TextFormField(
                autofocus: false,
                textInputAction: TextInputAction.send,
                controller: newMessage,
                onChanged: (value) {
                  final newIsSendIconVisible = value.isNotEmpty;
                  if (newIsSendIconVisible != isSendIconVisible) {
                    setState(() => isSendIconVisible = newIsSendIconVisible);
                  }
                },
                focusNode: focusNode,
                onFieldSubmitted: (value) async =>
                    value.isEmpty ? null : await handleSubmit(newMessage),
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
              if (isRecording)
                SizedBox(
                  child: Container(
                    decoration: BoxDecoration(color: grey2),
                  ),
                ),
            ],
          ),
          trailing: isSendIconVisible && !isRecording
              ? IconButton(
                  key: const ValueKey('send_message'),
                  icon: Icon(Icons.send, color: black),
                  onPressed: send,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isRecording
                        ? const SizedBox()
                        : IconButton(
                            onPressed: () async => await selectFilesToShare(),
                            icon:
                                const CAssetImage(path: ImagePaths.add_circle),
                          ),
                  ],
                ),
        ),
        VoiceRecorder(
          isRecording: isRecording,
          onRecording: () async => await startRecording(),
          onStopRecording: () async =>
              hasPermission ? await finishRecording() : null,
          onTapUpListener: () async => await finishRecording(),
        ),
      ],
    );
  }

  void send() async {
    if (newMessage.value.text.trim().isEmpty && recording == null) {
      return;
    }
    await sendMessage(newMessage.value.text,
        attachments:
            recording != null && recording!.isNotEmpty ? [recording!] : [],
        replyToSenderId: quotedMessage?.senderId,
        replyToId: quotedMessage?.id);
    if (mounted) {
      setState(() {
        quotedMessage = null;
        isRecording = false;
        finishedRecording = false;
        isSendIconVisible = false;
        isReplying = false;
      });
    }
  }
}

enum KeyboardMode { none, native, emoji, emojiReaction }

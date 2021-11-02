import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lantern/core/router/router.gr.dart' as router_gr;
import 'package:lantern/common/ui/dimens.dart';
import 'package:lantern/messaging/calls/call.dart';
import 'package:lantern/messaging/messaging.dart';

import 'contact_info_topbar.dart';
import 'audio/audio_widget.dart';
import 'audio/message_bar_preview_recording.dart';
import 'conversation_sticker.dart';
import 'message_bubble.dart';
import 'messaging_emoji_picker.dart';
import 'pulsating_indicator.dart';
import 'stopwatch_timer.dart';
import 'audio/voice_recorder.dart';
import 'call_action.dart';
import 'date_marker_bubble.dart';
import 'reply.dart';
import 'show_conversation_options.dart';
import 'show_verification_options.dart';

class Conversation extends StatefulWidget {
  final ContactId contactId;
  final int? initialScrollIndex;

  Conversation({required this.contactId, this.initialScrollIndex}) : super();

  @override
  ConversationState createState() => ConversationState();
}

class ConversationState extends State<Conversation>
    with WidgetsBindingObserver {
  static final dayFormat = intl.DateFormat.yMMMMd();

  late MessagingModel model;
  bool reactingWithEmoji = false;
  bool hasPermission = false;

  final TextEditingController newMessage = TextEditingController();
  final StopWatchTimer stopWatchTimer = StopWatchTimer();
  bool isRecording = false;
  bool finishedRecording = false;
  bool isSendIconVisible = false;
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
  static var latestKeyboardHeight = 0.0;

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
    if (currentKeyboardHeight > 0) {
      setState(() {
        latestKeyboardHeight = currentKeyboardHeight;
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

    context.loaderOverlay.show(widget: spinner);
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
      context.loaderOverlay.show(widget: spinner);
      for (var i = 0; i < result.files.length; i++) {
        final el = result.files[i];
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
        await sendMessage(newMessage.value.text,
            attachments: [attachment],
            replyToSenderId: quotedMessage?.senderId,
            replyToId: quotedMessage?.id);
      }
      setState(() => quotedMessage = null);
    } catch (e, s) {
      showErrorDialog(context, e: e, s: s, des: 'share_media_error'.i18n);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> handleMessageBarSubmit(TextEditingController newMessage) async {
    if (mounted) {
      setState(() {
        isSendIconVisible = false;
      });
    }
    await sendMessage(newMessage.value.text,
        replyToSenderId: quotedMessage?.senderId, replyToId: quotedMessage?.id);
  }

  // handles backend send message logic
  Future<void> sendMessage(String text,
      {List<Uint8List>? attachments,
      String? replyToSenderId,
      String? replyToId}) async {
    if (attachments?.isNotEmpty == true) {
      context.loaderOverlay.show(widget: spinner);
    }
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
        quotedMessage = null;
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

  // handles client send message logic
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();

    // update keyboard height values
    updateKeyboardHeight();

    final keyboardHeight =
        latestKeyboardHeight > 0 ? latestKeyboardHeight : defaultKeyboardHeight;

    (context.router.currentChild!.name == router_gr.Conversation.name)
        ? unawaited(model.setCurrentConversationContact(widget.contactId.id))
        : unawaited(model.clearCurrentConversationContact());
    return model.singleContactById(context, widget.contactId,
        (context, contact, child) {
      var shouldShowVerificationAlert = true;
      var tsSeenVerificationAlert =
          contact.applicationData['tsVerificationReminder']?.int_3;

      if (tsSeenVerificationAlert != null) {
        final twoWeeksInMillis = 14 *
            24 *
            60 *
            60 *
            1000; // in 14d * 24h * 60m * 60s * 1000 from now
        shouldShowVerificationAlert = DateTime.now().millisecondsSinceEpoch -
                tsSeenVerificationAlert.toInt() >=
            twoWeeksInMillis;
      }
      return BaseScreen(
        resizeToAvoidBottomInset: false,
        centerTitle: false,
        padHorizontal: false,
        // Conversation title (contact name)
        title: dismissKeyboardsOnTap(
          InkWell(
            focusColor: grey3,
            onTap: () async =>
                await context.pushRoute(ContactInfo(contact: contact)),
            child: ContactInfoTopBar(contact: contact),
          ),
        ),
        actions: [
          model.me((bottomModalContext, me, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (shouldShowVerificationAlert &&
                      contact.verificationLevel != VerificationLevel.VERIFIED)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        model.addOrUpdateDirectContact(contact.contactId.id,
                            contact.verificationLevel.name.toString(),
                            tsVerificationReminder:
                                DateTime.now().millisecondsSinceEpoch);
                        showVerificationOptions(
                            model: model,
                            contact: contact,
                            bottomModalContext: bottomModalContext);
                      },
                      icon: const CAssetImage(
                        path: ImagePaths.verification_alert,
                      ),
                    ),
                  CallAction(contact),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const CAssetImage(path: ImagePaths.more_vert),
                    onPressed: () => showConversationOptions(
                        model: model,
                        parentContext: bottomModalContext,
                        contact: contact),
                  )
                ],
              )),
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
                      padding:
                          const EdgeInsetsDirectional.only(start: 16, end: 16),
                      child: buildList(contact),
                    ),
                  ),
                ),
                // Reply container
                if (quotedMessage != null)
                  Reply(
                    model: model,
                    contact: contact,
                    message: quotedMessage!,
                    onCancelReply: () => setState(() => quotedMessage = null),
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

      // show sticker when we have no messages
      if (listItems.isEmpty) {
        return ConversationSticker(contact, messageCount);
      }

      // interesting discussion on ScrollablePositionedList over ListView https://stackoverflow.com/a/58924218
      return ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        initialScrollIndex: widget.initialScrollIndex ?? 0,
        reverse: true,
        physics: defaultScrollPhysics,
        itemCount: messageCount + 1,
        itemBuilder: (context, index) {
          if (index == messageCount) {
            // show sticker as first item
            return ConversationSticker(contact, messageCount);
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
        onOpenMenu: dismissAllKeyboards,
        onEmojiTap: () {
          setState(() {
            reactingWithEmoji = true;
            storedMessage = messageAndPath;
          });
          showEmojiKeyboard(true);
        },
        onReply: () {
          setState(() {
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

  // Entry point to audio waveform widget (MessageBarPreviewRecording)
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

  // Renders Emoji button, message bar and recording icon
  // Handles their functionality
  Widget buildMessageBarRecording(BuildContext context) {
    return Stack(
      alignment: isLTR(context) ? Alignment.bottomRight : Alignment.bottomLeft,
      children: [
        CListTile(
          height: messageBarHeight,
          endPadding: isSendIconVisible ? 0 : 48,
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
                        child: PulsatingIndicator(),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: StopwatchTimer(
                          stopWatchTimer: stopWatchTimer,
                          style:
                              tsSubtitle1.copiedWith(color: indicatorRed).short,
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
                  icon: keyboardMode == KeyboardMode.emoji ||
                          keyboardMode == KeyboardMode.emojiReaction
                      ? const CAssetImage(path: ImagePaths.keyboard)
                      : const CAssetImage(path: ImagePaths.insert_emoticon),
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
                onFieldSubmitted: (value) async => value.isEmpty
                    ? null
                    : await handleMessageBarSubmit(newMessage),
                decoration: InputDecoration(
                  // Send icon
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'message'.i18n,
                  border: const OutlineInputBorder(),
                ),
                style: tsSubtitle1
                    .copiedWith(color: isSendIconVisible ? black : grey5)
                    .short,
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
              ? Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 8, bottom: 8),
                      child:
                          VerticalDivider(thickness: 1, width: 1, color: grey3),
                    ),
                    IconButton(
                      key: const ValueKey('send_message'),
                      icon: mirrorLTR(
                        context: context,
                        child: CAssetImage(
                            path: ImagePaths.send_rounded, color: pink4),
                      ),
                      onPressed: send,
                    ),
                  ],
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
        if (!isSendIconVisible)
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
}

enum KeyboardMode { none, native, emoji, emojiReaction }

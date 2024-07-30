import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lantern/core/router/router.gr.dart' as router_gr;
import 'package:lantern/messaging/conversation/unaccepted_contact_sticker.dart';
import 'package:lantern/messaging/messaging.dart';

import 'audio/audio_widget.dart';
import 'audio/message_bar_preview_recording.dart';
import 'audio/voice_recorder.dart';
import 'call_action.dart';
import 'contact_info_topbar.dart';
import 'contact_name_dialog.dart';
import 'conversation_sticker.dart';
import 'date_marker_bubble.dart';
import 'message_bubble.dart';
import 'messaging_emoji_picker.dart';
import 'pulsating_indicator.dart';
import 'reply.dart';
import 'show_conversation_options.dart';
import 'show_verification_options.dart';
import 'stopwatch_timer.dart';

@RoutePage<void>(name: 'Conversation')
class Conversation extends StatefulWidget {
  final ContactId contactId;
  final int? initialScrollIndex;
  final bool showContactEditingDialog;

  Conversation({
    required this.contactId,
    this.initialScrollIndex,
    this.showContactEditingDialog = false,
  }) : super();

  @override
  ConversationState createState() => ConversationState();
}

class ConversationState extends State<Conversation>
    with WidgetsBindingObserver {
  bool reactingWithEmoji = false;
  bool hasPermission = false;
  bool showContactEditingDialog = false;
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
  var verifiedColor = black;
  var shouldShowVerificationAlert = true;

  // ********************** Keyboard Handling ***************************/
  final keyboardVisibilityController = KeyboardVisibilityController();
  StreamSubscription<bool>? keyboardSubscription;
  final focusNode = FocusNode();
  var keyboardMode = KeyboardMode.none;

  // default the below to reasonable value, it will get updated when the
  // keyboard displays
  double get defaultKeyboardHeight => MediaQuery.of(context).size.height * 0.4;
  static var latestKeyboardHeight = 0.0;

  Timer? currentConversationTimer;

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
    if (keyboardMode != KeyboardMode.native) {
      return;
    }

    var currentKeyboardHeight = max(
      EdgeInsets.fromViewPadding(
              View.of(context).padding, View.of(context).devicePixelRatio)
          .bottom,
      MediaQuery.of(context).viewInsets.bottom,
    );
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
        clearCurrentConversationContact();
        break;
      case AppLifecycleState.resumed:
      default:
        messagingModel.setCurrentConversationContact(widget.contactId.id);
        // repeatedly notify backend of current contact so it knows that it's
        // fresh
        currentConversationTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) =>
              messagingModel.setCurrentConversationContact(widget.contactId.id),
        );
        break;
    }
  }

  void clearCurrentConversationContact() {
    currentConversationTimer?.cancel();
    currentConversationTimer = null;
    messagingModel.clearCurrentConversationContact();
  }

  @override
  void initState() {
    super.initState();
    showContactEditingDialog = widget.showContactEditingDialog;
    WidgetsBinding.instance.addObserver(this);
    BackButtonInterceptor.add(interceptBackButton);
    subscribeToKeyboardChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    clearCurrentConversationContact();
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
    hasPermission = await messagingModel.startRecordingVoiceMemo();
    if (hasPermission) {
      stopWatchTimer.onResetTimer();
      stopWatchTimer.onStartTimer();
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
      // stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      stopWatchTimer.onStopTimer();
      recording = await messagingModel.stopRecordingVoiceMemo();
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

      // check file for size limit
      int totalSizeBytes =
          result.files.fold(0, (prev, file) => prev + file.size);
      double totalSizeMB =
          totalSizeBytes / (1024 * 1024); // Convert bytes to megabytes

      if (totalSizeMB > 100) {
        if(!mounted){
          return;
        }
        CDialog.showInfo(
          context,
          title: 'file_size_limit_title'.i18n,
          description: 'file_size_limit_description'.i18n,
        );
        return;
      }

      context.loaderOverlay.show(widget: spinner);
      for (var i = 0; i < result.files.length; i++) {
        final el = result.files[i];
        final fileExtension =
            el.path.toString().split('file_picker/')[1].split('.')[1];
        final title = el.path.toString().split('file_picker/')[1].split('.')[
            0]; // example path: /data/user/0/org.getlantern.lantern/cache/file_picker/alpha_png.png
        Uint8List? attachmentBytes;

        final metadata = {
          'title': title,
          'fileExtension': fileExtension,
        };
        if (fileExtension.isCompressSupported()) {
          final targetPath =
              '${el.path.toString().split('file_picker/')[0]}file_picker/${title}_compressed.$fileExtension';

          //Removing Metadata from attachments
          final stripedImage = await FlutterImageCompress.compressAndGetFile(
            el.path!,
            targetPath,
            format: fileExtension.getFormat(),
            keepExif: false, //this removes metadata from image
          );

          attachmentBytes = await messagingModel.filePickerLoadAttachment(
            stripedImage!.path.toString(),
            metadata,
          );
        } else {
          attachmentBytes = await messagingModel.filePickerLoadAttachment(
            el.path!.toString(),
            metadata,
          );
        }
        await sendMessage(
          newMessage.value.text,
          attachments: [attachmentBytes],
          replyToSenderId: quotedMessage?.senderId,
          replyToId: quotedMessage?.id,
        );
      }
      setState(() => quotedMessage = null);
    } catch (e, s) {
      CDialog.showError(
        context,
        error: e,
        stackTrace: s,
        description: 'share_media_error'.i18n,
      );
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
    await sendMessage(
      newMessage.value.text,
      replyToSenderId: quotedMessage?.senderId,
      replyToId: quotedMessage?.id,
    );
  }

  // handles backend send message logic
  Future<void> sendMessage(
    String text, {
    List<Uint8List>? attachments,
    String? replyToSenderId,
    String? replyToId,
  }) async {
    if (attachments?.isNotEmpty == true) {
      context.loaderOverlay.show(widget: spinner);
    }
    try {
      await messagingModel.sendToDirectContact(
        widget.contactId.id,
        text: text,
        attachments: attachments,
        replyToId: replyToId,
        replyToSenderId: replyToSenderId,
      );
      await sessionModel.trackUserAction('User sent message via Lantern Chat', '/message');
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
          curve: defaultCurves,
        );
      }
    } catch (e, s) {
      CDialog.showError(
        context,
        error: e,
        stackTrace: s,
        description: 'send_error'.i18n,
      );
    } finally {
      if (attachments?.isNotEmpty == true) context.loaderOverlay.hide();
    }
  }

  // handles client send message logic
  void send() async {
    if (newMessage.value.text.trim().isEmpty && recording == null) {
      return;
    }
    await sendMessage(
      newMessage.value.text,
      attachments:
          recording != null && recording!.isNotEmpty ? [recording!] : [],
      replyToSenderId: quotedMessage?.senderId,
      replyToId: quotedMessage?.id,
    );
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
    // update keyboard height values
    updateKeyboardHeight();

    final keyboardHeight =
        latestKeyboardHeight > 0 ? latestKeyboardHeight : defaultKeyboardHeight;

    (context.router.currentChild!.name == router_gr.Conversation.name)
        ? unawaited(
            messagingModel.setCurrentConversationContact(widget.contactId.id),
          )
        : unawaited(messagingModel.clearCurrentConversationContact());
    return messagingModel.singleContactById(widget.contactId,
        (context, contact, child) {
      // * we came here after adding a contact via chat number, show contact name dialog
      if (showContactEditingDialog == true && contact.displayName.isEmpty) {
        showContactEditingDialog = false;
        messagingModel
            .getDirectContact(widget.contactId.id)
            .then((contact) async {
          // We use Future.delayed instead of addPostFrameCallback because
          // addPostFrameCallback doesn't work all the time (for some unknown
          // reason).
          await Future.delayed(const Duration(milliseconds: 250));
          await showDialog(
            context: context,
            builder: (childContext) => ContactNameDialog(
              context: context,
              contact: contact,
            ),
          );
        });
      }

      // determine if we will show the verification warning badge
      var verificationReminderLastDismissed = contact
              .applicationData['verificationReminderLastDismissed']?.int_3
              .toInt() ??
          0;
      return BaseScreen(
        resizeToAvoidBottomInset: false,
        centerTitle: false,
        padHorizontal: false,
        // * Conversation Title
        title: dismissKeyboardsOnTap(
          CInkWell(
            onTap: () async =>
                await context.pushRoute(ContactInfo(contact: contact)),
            child: ContactInfoTopBar(
              contact: contact,
              verifiedColor: verifiedColor,
            ),
          ),
        ),
        // * Conversation Actions e.g. Verification alert, Call, Menu
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // * show Verification alert badge, resurface every 2 weeks
              NowBuilder(
                calculate: (now) =>
                    now.millisecondsSinceEpoch -
                        verificationReminderLastDismissed >=
                    twoWeeksInMillis,
                builder: (BuildContext context, bool value) {
                  if (!contact.isMe && contact.isUnverified() && value) {
                    return IconButton(
                      key: const ValueKey('verification_badge'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        showVerificationOptions(
                          contact: contact,
                          bottomModalContext: context,
                          showDismissNotification: shouldShowVerificationAlert,
                          topBarAnimationCallback: () async {
                            setState(() => verifiedColor = indicatorGreen);
                            await Future.delayed(
                              longAnimationDuration,
                              () => setState(() => verifiedColor = black),
                            );
                          },
                        );
                      },
                      icon: const CAssetImage(
                        path: ImagePaths.verification_alert,
                      ),
                    );
                  }
                  return Container();
                },
              ),
              if (!contact.isMe) CallAction(contact),
              IconButton(
                key: const ValueKey('conversation_topbar_more_menu'),
                visualDensity: VisualDensity.compact,
                icon: const CAssetImage(path: ImagePaths.more_vert),
                onPressed: () => showConversationOptions(
                  parentContext: context,
                  contact: contact,
                  topBarAnimationCallback: () async {
                    setState(() => verifiedColor = indicatorGreen);
                    await Future.delayed(
                      longAnimationDuration,
                      () => setState(() => verifiedColor = black),
                    );
                  },
                ),
              )
            ],
          ),
        ],
        // * Conversation body
        body: Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: keyboardMode == KeyboardMode.native ? keyboardHeight : 0.0,
          ),
          child: Column(
            children: [
              if (contact.isUnaccepted())
                UnacceptedContactSticker(
                  messageCount: messageCount,
                  contact: contact,
                ),
              Flexible(
                child: dismissKeyboardsOnTap(
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 16, end: 16),
                    child: buildList(contact),
                  ),
                ),
              ),
              // * Reply container
              if (quotedMessage != null)
                Reply(
                  contact: contact,
                  message: quotedMessage!,
                  onCancelReply: () => setState(() => quotedMessage = null),
                ),
              Divider(height: 1.0, color: grey3),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: messageBarHeight,
                ),
                child: Container(
                  color: isRecording ? grey2 : white,
                  width: MediaQuery.of(context).size.width,
                  child: buildMessageBar(),
                ),
              ),
              // * Emoji keyboard
              Offstage(
                offstage: keyboardMode != KeyboardMode.emoji &&
                    keyboardMode != KeyboardMode.emojiReaction,
                child: MessagingEmojiPicker(
                  height: keyboardHeight,
                  emptySuggestions: 'no_recents'.i18n,
                  onBackspacePressed: () {
                    newMessage
                      ..text = newMessage.text.characters.skipLast(1).toString()
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: newMessage.text.length),
                      );
                  },
                  onEmojiSelected: (category, emoji) async {
                    if (mounted && reactingWithEmoji && storedMessage != null) {
                      await messagingModel.react(
                        storedMessage!.value,
                        emoji.emoji,
                      );
                      reactingWithEmoji = false;
                      storedMessage = null;
                      dismissAllKeyboards();
                    } else {
                      setState(() => isSendIconVisible = true);
                      newMessage
                        ..text += emoji.emoji
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: newMessage.text.length),
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildList(Contact contact) {
    return messagingModel.contactMessages(
      contact,
      builder: (
        context,
        Iterable<PathAndValue<StoredMessage>> originalMessageRecords,
        Widget? child,
      ) {
        // Build list that includes original message records as well as date
        // separators.
        var listItems = <Object>[];
        String? priorDate;
        originalMessageRecords.forEach((messageRecord) {
          final locale = Localization.locale;
          final ts = DateTime.fromMillisecondsSinceEpoch(
            messageRecord.value.ts.toInt(),
          );
          final date = intl.DateFormat.yMMMMd(locale).format(ts);

          if (priorDate != null && date != priorDate) {
            listItems.add(priorDate.toString());
          }
          priorDate = date;
          listItems.add(messageRecord);
        });
        if (listItems.isNotEmpty) {
          // add leading date indicator
          listItems.add(priorDate.toString());
        }

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
              return buildMessageBubble(
                context,
                contact,
                listItems,
                item,
                index,
              );
            } else {
              return DateMarker(item as String);
            }
          },
        );
      },
    );
  }

  Widget buildMessageBubble(
    BuildContext context,
    Contact contact,
    List<Object> listItems,
    PathAndValue<StoredMessage> messageAndPath,
    int index,
  ) {
    return messagingModel.message(context, messageAndPath,
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
          final scrollToIndex = listItems.toList().indexWhere(
                (element) =>
                    element is PathAndValue<StoredMessage> &&
                    element.value.id == message.replyToId,
              );
          if (scrollToIndex != -1 && scrollController.isAttached) {
            scrollController.scrollTo(
              index: scrollToIndex,
              duration: const Duration(seconds: 1),
              curve: defaultCurves,
            );
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

  //* Entry point to audio waveform widget (MessageBarPreviewRecording)
  Widget buildMessageBar() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: IndexedStack(
        index: finishedRecording ? 1 : 0,
        children: [
          buildMessageBarRecording(context),
          audioPreviewController == null
              ? const SizedBox()
              : MessageBarPreviewRecording(
                  audioController: audioPreviewController!,
                  onCancelRecording: () async {
                    unawaited(HapticFeedback.lightImpact());
                    setState(() {
                      isRecording = false;
                      finishedRecording = false;
                      recording = null;
                      audioPreviewController = null;
                    });
                  },
                  onSend: () {
                    unawaited(HapticFeedback.lightImpact());
                    audio.stop();
                    send();
                  },
                ),
        ],
      ),
    );
  }

  //* Renders Emoji button, message bar and recording icon
  //* Handles their functionality
  Widget buildMessageBarRecording(BuildContext context) {
    final leading = isRecording
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
                    style: tsSubtitle1.copiedWith(color: indicatorRed).short,
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
          );

    final content = Stack(
      alignment: Alignment.center,
      children: [
        if (!isRecording)
          // using a SingleChildScrollView to reconcile emoji and native keyboard scrolling to latest character which is only possible with maxLines = null
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: TextFormField(
              // minLines: 1,
              // maxLines: 4,
              maxLines: null,
              autofocus: false,
              textInputAction: TextInputAction.send,
              onEditingComplete: () {},
              // prevents keyboard from closing on send
              controller: newMessage,
              onChanged: (value) {
                final newIsSendIconVisible = value.isNotEmpty;
                if (newIsSendIconVisible != isSendIconVisible) {
                  setState(() => isSendIconVisible = newIsSendIconVisible);
                }
              },
              focusNode: focusNode,
              textCapitalization: TextCapitalization.sentences,
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
              style: tsSubtitle1.copiedWith(
                color: isSendIconVisible ? black : grey5,
                lineHeight: 18,
              ),
            ),
          ),
        // hide TextFormField while recording by painting over it. this allows
        // the form field to retain focus to keep the keyboard open and keep
        // the layout from changing while we're recording.
        if (isRecording)
          SizedBox(
            height: messageBarHeight,
            child: Container(
              decoration: BoxDecoration(color: grey2),
            ),
          ),
      ],
    );
    final trailing = isSendIconVisible && !isRecording
        ? Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
                child: VerticalDivider(thickness: 1, width: 1, color: grey3),
              ),
              IconButton(
                key: const ValueKey('send_message'),
                icon: mirrorLTR(
                  context: context,
                  child:
                      CAssetImage(path: ImagePaths.send_rounded, color: pink4),
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
                      key: const ValueKey('filepicker_icon'),
                      onPressed: () async => await selectFilesToShare(),
                      icon: const CAssetImage(path: ImagePaths.add_circle),
                    ),
            ],
          );
    // * Stack overlay of [leading, content, trailing] Row and voice recorder
    return Stack(
      alignment: isLTR(context) ? Alignment.bottomRight : Alignment.bottomLeft,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: messageBarHeight),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // * Leading
              leading,
              // * Content
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  constraints:
                      const BoxConstraints(maxHeight: messageBarHeight * 2),
                  child: content,
                ),
              ),
              // * Trailing
              Padding(
                padding: EdgeInsetsDirectional.only(
                  end: isSendIconVisible ? 0 : 48,
                ),
                child: trailing,
              ),
            ],
          ),
        ),
        if (!isSendIconVisible)
          VoiceRecorder(
            key: const ValueKey('recorder_button'),
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

extension FileExtension on String {
  CompressFormat getFormat() {
    if (toLowerCase() == 'png') {
      return CompressFormat.png;
    }
    if (toLowerCase() == 'jpeg') {
      return CompressFormat.jpeg;
    }
    if (toLowerCase() == 'heic') {
      return CompressFormat.heic;
    }
    if (toLowerCase() == 'webp') {
      return CompressFormat.webp;
    }
    return CompressFormat.png;
  }

  bool isCompressSupported() {
    if (toLowerCase() == 'png' ||
        toLowerCase() == 'jpeg' ||
        toLowerCase() == 'heic' ||
        toLowerCase() == 'webp') {
      return true;
    }
    return false;
  }
}

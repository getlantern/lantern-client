import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:lantern/core/router/router.gr.dart' as router_gr;
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/conversation_components/conversation_sticker.dart';
import 'package:lantern/messaging/widgets/message_bubble.dart';
import 'package:lantern/messaging/widgets/conversation_components/countdown_timer.dart';
import 'package:lantern/messaging/widgets/conversation_components/disappearing_timer_action.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/messaging/widgets/messaging_emoji_picker.dart';
import 'package:lantern/messaging/widgets/reply/reply_preview.dart';
import 'package:lantern/messaging/widgets/voice_recorder/audio_widget.dart';
import 'package:lantern/messaging/widgets/voice_recorder/message_bar_preview_recording.dart';
import 'package:lantern/messaging/widgets/voice_recorder/voice_recorder.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sizer/sizer.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/services.dart';

class Conversation extends StatefulWidget {
  final ContactId _contactId;

  Conversation(this._contactId) : super();

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
  bool _isRecording = false;
  bool _finishedRecording = false;
  bool _isSendIconVisible = false;
  bool _isReplying = false;
  Uint8List? _recording;
  AudioController? _audioPreviewController;
  StoredMessage? _quotedMessage;
  bool _emojiShowing = false;
  final _focusNode = FocusNode();
  PathAndValue<StoredMessage>? _storedMessage;
  final _scrollController = ItemScrollController();
  StreamSubscription<bool>? keyboardStream;
  bool _keyboardState = true;

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
    var keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardState = !keyboardVisibilityController.isVisible;
    keyboardStream = keyboardVisibilityController.onChange.listen(
      (bool visible) => setState(
        () => _keyboardState = !visible,
      ),
    );
    BackButtonInterceptor.add(_interceptBackButton);
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    keyboardStream?.cancel();
    _newMessage.dispose();
    _stopWatchTimer.dispose();
    _focusNode.dispose();
    _audioPreviewController?.stop();
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
    if (attachments!.isNotEmpty) context.loaderOverlay.show();
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
      // TODO: this complains when there are no messages in the thread
      await _scrollController.scrollTo(
          index: 00,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOutCubic);
    } catch (e) {
      showInfoDialog(context,
          title: 'Error'.i18n,
          des: 'Something went wrong while sending your message.'.i18n,
          icon: ImagePaths.alert_icon,
          buttonText: 'OK'.i18n);
    } finally {
      if (attachments.isNotEmpty) context.loaderOverlay.hide();
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

  void showKeyboard() => _focusNode.requestFocus();

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
    } catch (e) {
      showInfoDialog(context,
          title: 'Error'.i18n,
          des: 'Something went wrong while sharing a media file.'.i18n,
          icon: ImagePaths.alert_icon,
          buttonText: 'OK'.i18n);
    } finally {
      context.loaderOverlay.hide();
    }
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
    (context.router.currentChild!.name == router_gr.Conversation.name &&
            context.router.routeData.router.current.name ==
                router_gr.MessagesRouter.name)
        ? unawaited(model.setCurrentConversationContact(widget._contactId.id))
        : unawaited(model.clearCurrentConversationContact());
    return WillPopScope(
      onWillPop: () => Future<bool>.value(_keyboardState),
      child: model.singleContactById(context, widget._contactId,
          (context, contact, child) {
        return BaseScreen(
          // Conversation title (contact name)
          title: contact.displayName.isEmpty
              ? contact.contactId.id
              : contact.displayName,
          centerTitle: false,
          actions: [
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.call),
                  tooltip: 'Call'.i18n,
                  onPressed: () {},
                ),
                IconButton(
                    onPressed: () {}, icon: DisappearingTimerAction(contact)),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  tooltip: 'Menu'.i18n,
                  onPressed: () =>
                      displayConversationOptions(model, context, contact),
                )
              ],
            )
          ],
          body: Stack(children: [
            Flex(
              direction: Axis.vertical,
              children: [
                Card(
                  color: grey1,
                  child: Container(
                    width: 70.w,
                    child: _buildConversationSticker(contact),
                  ),
                ),
                Flexible(
                  child: _buildMessageBubbles(contact),
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
                  color: _isRecording || _finishedRecording
                      ? Colors.grey[200]
                      : Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: kBottomNavigationBarHeight,
                  child: _buildMessageBar(),
                ),
                MessagingEmojiPicker(
                  showEmojis: _emojiShowing,
                  emptySuggestions: 'No Recents'.i18n,
                  height: size!.height * 0.25,
                  onBackspacePressed: () {
                    _newMessage
                      ..text =
                          _newMessage.text.characters.skipLast(1).toString()
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: _newMessage.text.length));
                  },
                  onEmojiSelected: (category, emoji) async {
                    if (_customEmojiResponse && _storedMessage != null) {
                      dismissKeyboard();
                      await model.react(_storedMessage!, emoji.emoji);
                      _storedMessage = null;
                      setState(() => _emojiShowing = false);
                    } else {
                      setState(() => _isSendIconVisible = true);
                      _newMessage
                        ..text += emoji.emoji
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: _newMessage.text.length));
                    }
                  },
                ),
              ],
            ),
          ]),
        );
      }),
    );
  }

  Widget _buildConversationSticker(Contact contact) =>
      model.introductionsToContact(builder: (context,
          Iterable<PathAndValue<StoredMessage>> introductions, Widget? child) {
        final isPendingIntroduction = !contact.hasReceivedMessage &&
            introductions
                .toList()
                .where(
                    (intro) => intro.value.introduction.to == contact.contactId)
                .isNotEmpty;
        return ConversationSticker(
            contact: contact, isPendingIntroduction: isPendingIntroduction);
      });

  Widget _buildMessageBubbles(Contact contact) {
    return model.contactMessages(contact, builder: (context,
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
                  contact: contact,
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

  Widget _buildMessageBar() {
    return Container(
      width: size!.width,
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
          ? Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 6.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 12,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6.0),
                    child: CountdownTimer(stopWatchTimer: _stopWatchTimer),
                  ),
                ),
              ],
            )
          : IconButton(
              onPressed: () {
                {
                  setState(() => _emojiShowing = !_emojiShowing);
                  dismissKeyboard();
                }
              },
              icon: Icon(Icons.sentiment_very_satisfied,
                  color: !_emojiShowing
                      ? Theme.of(context).primaryIconTheme.color
                      : Theme.of(context).primaryColorDark),
            ),
      title: _isRecording
          ? const SizedBox()
          : TextFormField(
              autofocus: false,
              textInputAction: TextInputAction.send,
              controller: _newMessage,
              onTap: () => setState(() => _emojiShowing = false),
              onChanged: (value) =>
                  setState(() => _isSendIconVisible = value.isNotEmpty),
              focusNode: _focusNode,
              onFieldSubmitted: (value) async =>
                  value.isEmpty ? null : await _handleSubmit(_newMessage),
              decoration: InputDecoration(
                // Send icon
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Message'.i18n,
                border: const OutlineInputBorder(),
              ),
            ),
      trailing: _isSendIconVisible && !_isRecording
          ? IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: send,
            )
          : Flex(
              direction: Axis.horizontal,
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
    setState(() {
      _quotedMessage = null;
      _isRecording = false;
      _finishedRecording = false;
      _isSendIconVisible = false;
      _isReplying = false;
      _emojiShowing = false;
    });
  }
}

typedef ShowEmojis = void Function(
    bool showEmoji, PathAndValue<StoredMessage>? messageStored);

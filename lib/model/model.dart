import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../i18n/i18n.dart';
import '../model/protobuf_message_codec.dart';
import 'model_event_channel.dart';
import 'protos/messaging.pb.dart';

class Model {
  var _methodChannel = MethodChannel(
      'methodChannel', StandardMethodCodec(ProtobufMessageCodec()));
  var _updatesChannel = ModelEventChannel('updatesChannel');

  Model() {
    // Use static list of conversations for now
    var conversationIDs = List<String>();
    for (var i = 0; i < 100; i++) {
      var contact = Contact.create();
      contact.userID = i.toString();
      contact.name = "Contact ${contact.userID}";
      put("/contact/${contact.userID}", contact);
      var conversation = Conversation.create();
      conversation.id = i.toString();
      conversation.userIDs.add(contact.userID);
      conversation.mostRecentMessage =
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
      conversation.mostRecentMessageTime = DateTime.now()
          .subtract(Duration(minutes: i, seconds: i + 1))
          .toTimestamp();
      put("/conversation/${conversation.id}", conversation);
      conversationIDs.add(conversation.id);
    }
    put("/conversationsByRecentActivity", conversationIDs);
  }

  Future<void> put<T>(String path, T value) async {
    _methodChannel.invokeMethod('put', <String, dynamic>{
      "path": path,
      "value": value,
    });
  }

  Future<List<T>> getRange<T>(String path, int start, int count) async {
    var intermediate =
        await _methodChannel.invokeMethod('getRange', <String, dynamic>{
      "path": path,
      "start": start,
      "count": count,
    });
    var result = List<T>();
    intermediate.forEach((element) => result.add(element as T));
    return result;
  }

  Future<List<T>> getRangeDetails<T>(
      String path, String detailsPrefix, int start, int count) async {
    var intermediate =
        await _methodChannel.invokeMethod('getRangeDetails', <String, dynamic>{
      "path": path,
      "detailsPrefix": detailsPrefix,
      "start": start,
      "count": count,
    });
    var result = List<T>();
    intermediate.forEach((element) => result.add(element as T));
    return result;
  }

  Future<List<ValueNotifier<T>>> getRangeDetailNotifiers<T>(String path,
      String detailsPrefix, int start, int count, T defaultValue) async {
    var list = await getRange(path, start, count);
    return Future.value(list.map((e) {
      var detailsPath = "$detailsPrefix/$e";
      return buildValueNotifier(detailsPath, defaultValue);
    }).toList());
  }

  ValueNotifier<T> buildValueNotifier<T>(String path, T defaultValue) {
    return SubscribedValueNotifier(path, defaultValue, _updatesChannel);
  }

  ValueListenableBuilder<T> subscribedBuilder<T>(String path,
      {@required T defaultValue, @required ValueWidgetBuilder<T> builder}) {
    var notifier = buildValueNotifier(path, defaultValue);
    return SubscribedBuilder<T>(path, notifier, builder);
    // TODO: provide a mechanism for canceling subscriptions
  }
}

class SubscribedValueNotifier<T> extends ValueNotifier<T> {
  void Function() cancel;

  SubscribedValueNotifier(String path, T defaultValue, ModelEventChannel channel): super(defaultValue) {
    cancel = channel.subscribe(
        path: path,
        defaultValue: defaultValue,
        onNewValue: (dynamic newValue) {
          value = newValue as T;
        });
  }
}

class SubscribedBuilder<T> extends ValueListenableBuilder<T> {
  final SubscribedValueNotifier<T> _notifier;
  final String _path;

  SubscribedBuilder(
      this._path, this._notifier, ValueWidgetBuilder<T> builder)
      : super(valueListenable: _notifier, builder: builder);

  @override
  _SubscribedBuilderState createState() => _SubscribedBuilderState<T>();

  // @override
  // void dispose() {
  //   // TODO: unsubscribe listener
  //   super.dispose();
  // }
}

class _SubscribedBuilderState<T> extends State<ValueListenableBuilder<T>> {
  T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder<T> oldWidget) {
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    (widget.valueListenable as SubscribedValueNotifier).cancel();
    super.dispose();
  }

  void _valueChanged() {
    setState(() { value = widget.valueListenable.value; });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}

import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

Map<String, List<dynamic>> constructReactionsMap(StoredMessage msg) {
  // TODO: create reactions from received msg.reactions
  var reactorId_emoticon_map = {};
  var reactions = {
    '👍': [],
    '👎': [],
    '😄': [],
    '❤': [],
    '😢': [],
  };
  Map.fromIterables(msg.reactions.keys, msg.reactions.values)
      // isolate reactorID <---> emoticon
      .forEach((key, value) => reactorId_emoticon_map[key] = value.emoticon);

  // swap keys-values to create emoticon <--> List<reactorId>
  reactorId_emoticon_map
      .forEach((key, value) => reactions[value] = [key.toString()]);

  return reactions;
}

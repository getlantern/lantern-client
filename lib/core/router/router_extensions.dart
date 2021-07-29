import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

extension RouterExtensions on BuildContext {
  Future<T?> openConversation<T extends Object?>(Contact contact) {
    return innerRouterOf<TabsRouter>(Home.name)!
        .innerRouterOf<StackRouter>(MessagesRouter.name)!
        .push(Conversation(contact: contact));
  }
}

import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/messaging/messaging_model.dart';

import 'add_dummy_contacts_command.dart';

class AddDummyContactsCommandExtension extends CommandExtension {
  @override
  String get commandKind => 'AddDummyContactsCommand';

  @override
  Future<Result> call(
    Command command,
    WidgetController prober,
    CreateFinderFactory finderFactory,
    CommandHandlerFactory handlerFactory,
  ) async {
    try {
      messagingModel.addDummyContacts();
      return const AddDummyContactsCommandResult(true);
    } catch (e) {
      print('something went wrong while adding dummy contacts');
      return const AddDummyContactsCommandResult(false);
    }
  }

  @override
  Command deserialize(
      Map<String, String> params,
      DeserializeFinderFactory finderFactory,
      DeserializeCommandFactory commandFactory) {
    return AddDummyContactsCommand.deserialize(params);
  }
}

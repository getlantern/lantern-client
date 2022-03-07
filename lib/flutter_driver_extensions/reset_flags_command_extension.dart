import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/messaging/messaging_model.dart';

import 'reset_flags_command.dart';

class ResetFlagsCommandExtension extends CommandExtension {
  @override
  String get commandKind => 'ResetFlagsCommand';

  @override
  Future<Result> call(
    Command command,
    WidgetController prober,
    CreateFinderFactory finderFactory,
    CommandHandlerFactory handlerFactory,
  ) async {
    try {
      await messagingModel.resetFlags();
      await messagingModel.resetTimestamps();
      return const ResetFlagsCommandResult(true);
    } catch (e) {
      print('something went wrong while resetting Chat flags and timestamps');
      return const ResetFlagsCommandResult(false);
    }
  }

  @override
  Command deserialize(
    Map<String, String> params,
    DeserializeFinderFactory finderFactory,
    DeserializeCommandFactory commandFactory,
  ) {
    return ResetFlagsCommand.deserialize(params);
  }
}

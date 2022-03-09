import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app.dart';
import '../common/common.dart';
import 'navigate_command.dart';

class NavigateCommandExtension extends CommandExtension {
  @override
  String get commandKind => 'NavigateCommand';

  @override
  Future<Result> call(
    Command command,
    WidgetController prober,
    CreateFinderFactory finderFactory,
    CommandHandlerFactory handlerFactory,
  ) async {
    final navigateCommand = command as NavigateCommand;

    switch (navigateCommand.path) {
      case NavigateCommand.home:
        navigatorKey.currentContext?.router.popUntilRoot();
        return const NavigateCommandResult(true);
    }

    return const NavigateCommandResult(false);
  }

  @override
  Command deserialize(
      Map<String, String> params,
      DeserializeFinderFactory finderFactory,
      DeserializeCommandFactory commandFactory) {
    return NavigateCommand.deserialize(params);
  }
}

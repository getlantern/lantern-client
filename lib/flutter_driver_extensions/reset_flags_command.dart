import 'package:flutter_driver/flutter_driver.dart';

class ResetFlagsCommand extends Command {
  ResetFlagsCommand({Duration? timeout}) : super(timeout: timeout);

  @override
  String get kind => 'ResetFlagsCommand';

  ResetFlagsCommand.deserialize(Map<String, String> json)
      : super.deserialize(json);

  @override
  Map<String, String> serialize() {
    return super.serialize();
  }
}

class ResetFlagsCommandResult extends Result {
  const ResetFlagsCommandResult(this.isDevPanelHidden);

  final bool isDevPanelHidden;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isDevPanelHidden': true,
    };
  }
}

import 'package:flutter_driver/flutter_driver.dart';

class SendDummyFilesCommand extends Command {
  SendDummyFilesCommand({Duration? timeout}) : super(timeout: timeout);

  @override
  String get kind => 'SendDummyFilesCommand';

  SendDummyFilesCommand.deserialize(Map<String, String> json)
      : super.deserialize(json);

  @override
  Map<String, String> serialize() {
    return super.serialize();
  }
}

class SendDummyFilesCommandResult extends Result {
  const SendDummyFilesCommandResult(this.sent);

  final bool sent;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sent': true,
    };
  }
}

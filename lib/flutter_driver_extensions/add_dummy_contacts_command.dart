import 'package:flutter_driver/flutter_driver.dart';

class AddDummyContactsCommand extends Command {
  AddDummyContactsCommand({Duration? timeout}) : super(timeout: timeout);

  @override
  String get kind => 'AddDummyContactsCommand';

  AddDummyContactsCommand.deserialize(Map<String, String> json)
      : super.deserialize(json);

  @override
  Map<String, String> serialize() {
    return super.serialize();
  }
}

class AddDummyContactsCommandResult extends Result {
  const AddDummyContactsCommandResult(this.added);

  final bool added;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'added': true,
    };
  }
}

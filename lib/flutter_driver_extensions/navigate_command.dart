import 'package:flutter_driver/flutter_driver.dart';

class NavigateCommand extends Command {
  static const String home = 'home';

  NavigateCommand(this.path, {Duration? timeout}) : super(timeout: timeout);

  @override
  String get kind => 'NavigateCommand';

  final String path;

  NavigateCommand.deserialize(Map<String, String> json)
      : path = json['path']!,
        super.deserialize(json);

  @override
  Map<String, String> serialize() {
    return super.serialize()..addAll(<String, String>{'path': path});
  }
}

class NavigateCommandResult extends Result {
  const NavigateCommandResult(this.navigated);

  final bool navigated;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'navigated': true,
    };
  }
}

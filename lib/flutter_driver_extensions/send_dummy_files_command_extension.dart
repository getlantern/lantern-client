import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/messaging/messaging_model.dart';

import 'send_dummy_files_command.dart';

class SendDummyFilesCommandExtension extends CommandExtension {
  @override
  String get commandKind => 'SendDummyFilesCommand';

  @override
  Future<Result> call(
    Command command,
    WidgetController prober,
    CreateFinderFactory finderFactory,
    CommandHandlerFactory handlerFactory,
  ) async {
    try {
      // download video from URL and save to storage
      await Future.wait([
        // file:///storage/emulated/0/Android/data/org.getlantern.lantern/files/testing/test_image.jpg
        messagingModel.saveDummyAttachment(
          'https://d2w9rnfcy7mm78.cloudfront.net/1071899/original_6f46cf68dbdec64a3715e98a9ab3cb8c.jpg',
          'test_image.jpg',
        ),
        // file:///storage/emulated/0/Android/data/org.getlantern.lantern/files/testing/test_video.mov
        messagingModel.saveDummyAttachment(
          'https://filesamples.com/samples/video/mov/sample_640x360.mov',
          'test_video.mov',
        ),
      ]);

      // create attachment in messaging and send to direct contact
      await Future.wait([
        messagingModel.sendDummyAttachment('test_image.jpg', {
          'fileName': 'test_image.jpg',
          'fileExtension': 'jpg',
        }),
        messagingModel.sendDummyAttachment('test_video.mov', {
          'fileName': 'test_video.mov',
          'fileExtension': 'mov',
        }),
      ]);
      return const SendDummyFilesCommandResult(true);
    } catch (e) {
      print('something went wrong while downloading and sharing dummy files');
      return const SendDummyFilesCommandResult(false);
    }
  }

  @override
  Command deserialize(
    Map<String, String> params,
    DeserializeFinderFactory finderFactory,
    DeserializeCommandFactory commandFactory,
  ) {
    return SendDummyFilesCommand.deserialize(params);
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:lantern/package_store.dart';

// in case we hook this to a listener
enum PickerState { loading, error, success }

class CustomFilePicker {
  late List<PlatformFile>? paths;
  late String? directoryPath;
  final bool multiPick = true;
  // we should be able to use FileType.any but it throws exception
  final FileType pickingType = FileType.custom;

  Future<List<PlatformFile>?> openFileExplorer() async {
    final audioExtensions = getExtensionFromMimeList(audioMimes);
    final videoExtensions = getExtensionFromMimeList(videoMimes);
    final imageExtensions = getExtensionFromMimeList(imageMimes);
    final allowedExtensions = [
      ...audioExtensions,
      ...videoExtensions,
      ...imageExtensions
    ];
    PickerState.loading;
    try {
      directoryPath = null;
      paths = (await FilePicker.platform.pickFiles(
              type: pickingType,
              allowMultiple: multiPick,
              allowedExtensions: allowedExtensions))
          ?.files;
    } on PlatformException catch (e) {
      PickerState.error;
      print(e);
    } catch (ex) {
      print(ex);
    } finally {
      PickerState.success;
    }
    return paths;
  }

  // not currently in use but potentially useful
  // Future<String?> selectFolder() async =>
  //     await FilePicker.platform.getDirectoryPath().then((value) {
  //       return value;
  //     });
}

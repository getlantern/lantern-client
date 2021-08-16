import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbenum.dart';

extension IntroductionExtension on Iterable<PathAndValue<StoredMessage>> {
  Iterable<PathAndValue<StoredMessage>> getPending() {
    return [...this]
        .where((intro) =>
            intro.value.introduction.status ==
            IntroductionDetails_IntroductionStatus.PENDING)
        .toList();
  }
}

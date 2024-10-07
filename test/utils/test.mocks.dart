import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/replica/models/replica_model.dart';
import 'package:mockito/annotations.dart';

/// All generate mock should happened or add here
/// For generate mock run flutter pub run build_runner build --delete-conflicting-outputs
/// So for most other test cases we need import only one class
@GenerateNiceMocks([
  MockSpec<SessionModel>(),
  MockSpec<VpnModel>(),
  MockSpec<MessagingModel>(),
  MockSpec<ReplicaModel>(),
])
void main() {}

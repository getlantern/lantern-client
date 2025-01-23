

import 'test_common.dart';

class MockBuildContext extends Mock implements BuildContext {}


// Reusable function to stub session model
void stubSessionModel({
  required MockSessionModel mockSessionModel,
  required MockBuildContext mockBuildContext,
  ValueNotifier<bool>? proxyAvailable,
  bool proUser = false,
  bool splitTunneling = false,
  String shouldShowAds = "",
  ServerInfo? serverInfo,
  Bandwidth? bandwidth,
}) {
  when(mockSessionModel.proxyAvailable)
      .thenAnswer((_) => proxyAvailable ?? ValueNotifier(true));

  when(mockSessionModel.proUser(any)).thenAnswer((invocation) {
    final builder =
    invocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
    return builder(mockBuildContext, proUser, null);
  });

  when(mockSessionModel.shouldShowAds(any)).thenAnswer((invocation) {
    final builder =
    invocation.positionalArguments[0] as ValueWidgetBuilder<String>;
    return builder(mockBuildContext, shouldShowAds, null);
  });

  when(mockSessionModel.serverInfo(any)).thenAnswer((invocation) {
    final builder =
    invocation.positionalArguments[0] as ValueWidgetBuilder<ServerInfo?>;
    return builder(mockBuildContext, serverInfo, null);
  });

  when(mockSessionModel.bandwidth(any)).thenAnswer((invocation) {
    final builder =
    invocation.positionalArguments[0] as ValueWidgetBuilder<Bandwidth>;
    var usedData = Bandwidth()
      ..mibAllowed = Int64(250)
      ..mibUsed = Int64(200)
      ..percent = Int64(28);
    return builder(mockBuildContext, bandwidth ?? usedData, null);
  });

  when(mockSessionModel.splitTunneling(any)).thenAnswer((invocation) {
    final builder =
    invocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
    return builder(mockBuildContext, splitTunneling, null);
  });
}


void stubVpnModel({
  required MockVpnModel mockVpnModel,
  required MockBuildContext mockBuildContext,
  String vpnStatus = 'disconnected',
}) {
  when(mockVpnModel.vpnStatus(any, any)).thenAnswer(
        (realInvocation) {
      final builder = realInvocation.positionalArguments[1]
      as ValueWidgetBuilder<String>;
      return builder(mockBuildContext, 'disconnected', null);
    },
  );
}
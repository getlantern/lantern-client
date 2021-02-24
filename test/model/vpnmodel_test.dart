import 'package:test/test.dart';
import '../../lib/model/vpnmodel.dart';

void main() {
  test('VPN status should toggle', () {
    final model = VPNModel();
    expect(model.vpnOn, false);
    model.toggle();
    expect(model.vpnOn, true);
    model.toggle();
    expect(model.vpnOn, false);

    var capResetsAt = DateTime.now();
    model.updateBandwidthUsage(100, 200, capResetsAt);
    expect(model.bandwidthUsed, 100);
    expect(model.dataCap, 200);
    expect(model.dataCapUsedPercentage, .5);
    expect(model.capResetsAt, capResetsAt);
  });
}
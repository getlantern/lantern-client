import 'package:lantern/common/ui/custom/logo_with_text.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'DeviceLimit')
class DeviceLimit extends StatefulWidget {
  const DeviceLimit({super.key});

  @override
  State<DeviceLimit> createState() => _DeviceLimitState();
}

class _DeviceLimitState extends State<DeviceLimit> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      automaticallyImplyLeading: false,
      title: 'device_limit_reached'.i18n,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        LogoWithText(),
      ],
    );
  }
}

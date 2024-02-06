// ignore_for_file: use_build_context_synchronously

import '../../common/common.dart';

@RoutePage<void>(name: 'DeviceLimit')
class DeviceLimit extends StatefulWidget {
  const DeviceLimit({super.key});

  @override
  State<DeviceLimit> createState() => _DeviceLimitState();
}

class _DeviceLimitState extends State<DeviceLimit> {
  Device? selectedDevice;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'device_limit_reached'.i18n,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 24),
        const LogoWithText(),
        const SizedBox(height: 24),
        CText("device_limit_reached_message".i18n, style: tsBody1),
        userDeviceSelection(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Button(
            text: 'remove',
            disabled: selectedDevice == null,
            onPressed: onRemove,
          ),
        )
      ],
    );
  }

  Widget userDeviceSelection() {
    return sessionModel.devices((context, devices, child) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: devices.devices.length,
          itemBuilder: (context, index) {
            final device = devices.devices[index];
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: ListItemFactory.settingsItem(
                header: index == 0 ? 'pro_devices_header'.i18n : null,
                content: device.name,
                onTap: () {
                  setState(() {
                    selectedDevice = device;
                  });
                },
                trailingArray: [
                  CAssetImage(
                    path: selectedDevice?.id == device.id
                        ? ImagePaths.check_green
                        : ImagePaths.emptyCheck,
                  ),
                ],
              ),
            );
          });
    });
  }

  Future<void> onRemove() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.removeDevice(selectedDevice!.id);
      context.loaderOverlay.hide();
      // Once device has been removed
      // Pop routes and continue with sign in
      context.popRoute(true);
    } catch (e) {
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }
}

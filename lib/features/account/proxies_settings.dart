import 'package:lantern/core/utils/common.dart';

@RoutePage(name: 'ProxiesSetting')
class ProxiesSetting extends StatelessWidget {
  const ProxiesSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'proxy_settings'.i18n,
      body: _buildBody(context),
      padHorizontal: true,
      padVertical: true,
    );
  }

  Widget _buildBody(BuildContext context) {
    final config = sessionModel.configNotifier.value;
    return Column(
      children: <Widget>[
        ListItemFactory.settingsItem(
            header: 'http_proxy'.i18n,
            content: CText(config?.httpProxyAddr ?? '', style: tsBody1),
            trailingArray: [SvgPicture.asset(ImagePaths.copy)],
            onTap: () => copyText(context, config?.httpProxyAddr ?? '')),
        ListItemFactory.settingsItem(
          header: 'socks_proxy'.i18n,
          content: CText(config?.socksProxyAddr ?? '', style: tsBody1),
          onTap: () => copyText(context, config?.socksProxyAddr ?? ''),
          trailingArray: [SvgPicture.asset(ImagePaths.copy)],
        )
      ],
    );
  }
}

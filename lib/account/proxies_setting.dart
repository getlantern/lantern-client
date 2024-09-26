import '../common/common.dart';

@RoutePage(name: 'ProxiesSetting')
class ProxiesSetting extends StatefulWidget {
  const ProxiesSetting({super.key});

  @override
  State<ProxiesSetting> createState() => _ProxiesSettingState();
}

class _ProxiesSettingState extends State<ProxiesSetting> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'proxy_setting'.i18n,
      body: _buildBody(),
      padHorizontal: true,
      padVertical: true,
    );
  }

  Widget _buildBody() {
    final config = sessionModel.configNotifier.value;
    return Column(
      children: <Widget>[
        ListItemFactory.settingsItem(
          header: 'http_proxy'.i18n,
          content: CText(config?.httpProxyAddr ?? '', style: tsBody1),
          trailingArray: [SvgPicture.asset(ImagePaths.copy)],
          onTap: () => copyHttpProxy(config?.httpProxyAddr??''),
        ),
        ListItemFactory.settingsItem(
          header: 'socks_proxy'.i18n,
          content: CText(config?.socksProxyAddr ?? '', style: tsBody1),
          onTap: () => copySocksProxy(config?.httpProxyAddr??''),
          trailingArray: [SvgPicture.asset(ImagePaths.copy)],
        )
      ],
    );
  }

  void copyHttpProxy(String address) {
    copyText(context, address);
    showSnackbar(context: context, content: 'http_proxy_copied'.i18n);
  }

  void copySocksProxy(String address) {
    copyText(context, address);
    showSnackbar(context: context, content: 'socks_proxy_copied'.i18n);
  }
}

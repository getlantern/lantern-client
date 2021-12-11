import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:lantern/replica/ui/markdown_link_builder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/logic/markdown_link_builder.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:markdown/markdown.dart' as md;
import 'settings_item.dart';

class DeveloperSettingsTab extends StatelessWidget {
  final replicaApi = ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);

  DeveloperSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Developer Settings'.i18n,
      padVertical: true,
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 16.0),
            child: CText(
              'dev_settings'.i18n,
              style: tsBody3,
            ),
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 16.0),
            child: CText('dev_payment_mode'.i18n, style: tsBody3),
          ),
          ListItemFactory.settingsItem(
            content: 'Payment Test Mode'.i18n,
            trailingArray: [
              sessionModel.paymentTestMode(
                  (BuildContext context, bool value, Widget? child) {
                return FlutterSwitch(
                  width: 44.0,
                  height: 24.0,
                  valueFontSize: 12.0,
                  padding: 2,
                  toggleSize: 18.0,
                  value: value,
                  onToggle: (bool newValue) {
                    sessionModel.setPaymentTestMode(newValue);
                  },
                );
              })
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Play Version'.i18n,
            trailingArray: [
              sessionModel.playVersion(
                  (BuildContext context, bool value, Widget? child) {
                return FlutterSwitch(
                  width: 44.0,
                  height: 24.0,
                  valueFontSize: 12.0,
                  padding: 2,
                  toggleSize: 18.0,
                  value: value,
                  onToggle: (bool newValue) {
                    sessionModel.setPlayVersion(newValue);
                  },
                );
              })
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Force Country'.i18n,
            trailingArray: [
              sessionModel.forceCountry(
                  (BuildContext context, String value, Widget? child) {
                return DropdownButton<String>(
                  value: value,
                  icon: const CAssetImage(path: ImagePaths.arrow_down),
                  iconSize: iconSize,
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    sessionModel
                        .setForceCountry(newValue == '' ? null : newValue);
                  },
                  items: <String>['', 'CN', 'IR', 'US']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: CText(value, style: tsBody1),
                    );
                  }).toList(),
                );
              })
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Reset all timestamps',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.resetTimestamps();
                  },
                  child: CText('Reset'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Reset onboarding and recovery key flags',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.resetFlags();
                  },
                  child: CText('Reset'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Start messaging',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.start();
                  },
                  child: CText('start'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Kill messaging',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.kill();
                  },
                  child: CText('kill'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Wipe data and restart',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.wipeData();
                  },
                  child: CText('Wipe'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          Button(
            width: 200,
            text: 'Play random video',
            secondary: true,
            onPressed: () async => await context.pushRoute(ReplicaVideoPlayerScreen(
                replicaLink: ReplicaLink.New(
                    'magnet%3A%3Fxt%3Durn%3Abtih%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26xs%3Dreplica%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26dn%3DToto%2B-%2BRosanna%2B(Official%2BMusic%2BVideo).mp4%26so%3D0')!)),
          ),
          Button(
            width: 200,
            text: 'Play random audio',
            secondary: true,
            onPressed: () async => await context.pushRoute(ReplicaAudioPlayerScreen(
                replicaLink: ReplicaLink.New(
                    'magnet%3A%3Fxt%3Durn%3Abtih%3A4915e9ff7c162ea784e466de665b03f1de654edb%26xs%3Dreplica%3A4915e9ff7c162ea784e466de665b03f1de654edb%26dn%3D1.mp3%26so%3D0')!)),
          ),
          Button(
            width: 200,
            text: 'Download random link',
            secondary: true,
            onPressed: () async {
              await replicaApi.download(ReplicaLink.New(
                  'magnet%3A%3Fxt%3Durn%3Abtih%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26xs%3Dreplica%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26dn%3DToto%2B-%2BRosanna%2B(Official%2BMusic%2BVideo).mp4%26so%3D0')!);
            },
          ),
          MarkdownBody(
            data:
                '''This is a markdown text blob. Only the links starting with replica:// count.

  replica://
    Nothing happens here: the link is empty

  hello world!
    Nothing happens here

  bunnyfoofooreplica://
    Nothing happens here

  replica://bunnyfoofoo
    This link counts

  replica://AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

  replica://magnet:?xt=urn:btih:6a9759bffd5c0af65319979fb7832189f4f3c35d&dn=sintel.mp4
    This link counts

  replica://xt=urn:btih:6a9759bffd5c0af65319979fb7832189f4f3c35d&dn=sintel.mp4
    This link does not count since it has no leading 'magnet:?'

  magnet://xt=urn:btih:32729D0D089180D1095279069148DDC27323188B&dn=The%20Suicide%20Squad%20(2021)%20%5B1080p%5D%20%5BWEBRip%5D%20%5B5.1%5D%20&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2780%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&so=0
    This link does not count because it has the wrong prefix

  replica://AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    This link does count because we accept plain sha1 hexes

  http://www.google.com
    This link does not count

  A link at the end of the text also works
        replica://BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB''',
            builders: {
              'replica': ReplicaLinkMarkdownElementBuilder((replicaLink) {
                context.pushRoute(LinkOpenerScreen(replicaLink: replicaLink));
              }),
            },
            extensionSet: md.ExtensionSet.gitHubFlavored,
            inlineSyntaxes: <md.InlineSyntax>[ReplicaLinkSyntax()],
          ),
        ],
      ),
    );
  }
}

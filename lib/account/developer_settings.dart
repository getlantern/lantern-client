import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/common/common_desktop.dart';

class DeveloperSettingsTab extends StatelessWidget {
  DeveloperSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return replicaModel.withReplicaApi((context, replicaApi, child) {
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
                    key: AppKeys.payment_mode_switch,
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
                      if (isMobile()) {
                        sessionModel
                          .setForceCountry(newValue == '' ? null : newValue);
                      } else {
                        setForceCountry(newValue);
                      }
                    },
                    items: <String>['', 'CN', 'IR', 'US', 'RU']
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
            // * RESET ALL TIMESTAMPS
            ListItemFactory.settingsItem(
              content: 'Reset all timestamps',
              trailingArray: [
                TextButton(
                  onPressed: () async {
                    await messagingModel.resetTimestamps();
                  },
                  child: CText(
                    'Reset Timestamps'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepPurpleAccent),
                  ),
                )
              ],
            ),
            // * RESET REPLICA SHOW NEW BADGE
            ListItemFactory.settingsItem(
              content: 'Reset replica new badge',
              trailingArray: [
                TextButton(
                  onPressed: () async {
                    await replicaModel.setShowNewBadge(true);
                  },
                  child: CText(
                    'Reset Badge'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepPurpleAccent),
                  ),
                )
              ],
            ),
            // * RESET ONBOARDING + RECOVERY KEY FLAGS
            ListItemFactory.settingsItem(
              content: 'Reset chat flags',
              trailingArray: [
                TextButton(
                  onPressed: () async {
                    await messagingModel.resetFlags();
                  },
                  child: CText(
                    'Reset Flags'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepPurpleAccent),
                  ),
                )
              ],
            ),
            // * START MESSAGING
            ListItemFactory.settingsItem(
              content: 'Start messaging',
              trailingArray: [
                TextButton(
                  onPressed: () async {
                    await messagingModel.start();
                  },
                  child: CText(
                    'start'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepPurpleAccent),
                  ),
                )
              ],
            ),
            // * KILL MESSAGING
            ListItemFactory.settingsItem(
              content: 'Kill messaging',
              trailingArray: [
                TextButton(
                  onPressed: () async {
                    await messagingModel.kill();
                  },
                  child: CText(
                    'kill'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepPurpleAccent),
                  ),
                )
              ],
            ),
            // * WIPE DATA
            ListItemFactory.settingsItem(
              content: 'Wipe data and restart',
              trailingArray: [
                TextButton(
                  onPressed: () async {
                    await messagingModel.wipeData();
                  },
                  child: CText(
                    'Wipe'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepPurpleAccent),
                  ),
                )
              ],
            ),
            // * ADD DUMMY CONTACTS
            ListItemFactory.settingsItem(
              content: 'Add dummy contacts',
              trailingArray: [
                TextButton(
                  onPressed: () {
                    messagingModel.addDummyContacts();
                    showSnackbar(context: context, content: 'Added 👍');
                  },
                  child: CText(
                    'Add'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepPurpleAccent),
                  ),
                )
              ],
            ),
            // * COPY MY CONTACTID
            messagingModel.me(
              (context, me, child) => ListItemFactory.settingsItem(
                content: 'Copy my contact ID',
                trailingArray: [
                  TextButton(
                    onPressed: () => copyText(context, me.contactId.id),
                    child: CText(
                      'Copy'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent),
                    ),
                  )
                ],
              ),
            ),
            // * REPLICA TEST VIDEO
            ListItemFactory.settingsItem(
              content: 'Replica - test video',
              trailingArray: [
                TextButton(
                  child: CText(
                    'Play'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepOrangeAccent),
                  ),
                  onPressed: () async => await context.pushRoute(
                    ReplicaVideoViewer(
                      replicaApi: replicaApi,
                      item: ReplicaSearchItem(
                        'displayName',
                        'primaryMimeType',
                        'humanizedLastModified',
                        'humanizedFileSize',
                        ReplicaLink.New(
                          'magnet%3A%3Fxt%3Durn%3Abtih%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26xs%3Dreplica%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26dn%3DToto%2B-%2BRosanna%2B(Official%2BMusic%2BVideo).mp4%26so%3D0',
                        )!,
                        'description',
                        'title',
                        'serpTitle',
                        'serpSnippet',
                        'serpSource',
                        'serpDate',
                        'serpLink',
                      ),
                      category: SearchCategory.Video,
                    ),
                  ),
                )
              ],
            ),
            // * REPLICA TEST AUDIO
            ListItemFactory.settingsItem(
              content: 'Replica - test audio',
              trailingArray: [
                TextButton(
                  child: CText(
                    'Play'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepOrangeAccent),
                  ),
                  onPressed: () async => await context.pushRoute(
                    ReplicaAudioViewer(
                      replicaApi: replicaApi,
                      category: SearchCategory.Audio,
                      item: ReplicaSearchItem(
                        'audio test',
                        'mp3',
                        'humanizedLastModified',
                        'humanizedFileSize',
                        ReplicaLink.New(
                          'magnet%3A%3Fxt%3Durn%3Abtih%3A4915e9ff7c162ea784e466de665b03f1de654edb%26xs%3Dreplica%3A4915e9ff7c162ea784e466de665b03f1de654edb%26dn%3D1.mp3%26so%3D0',
                        )!,
                        'description',
                        'title',
                        'serpTitle',
                        'serpSnippet',
                        'serpSource',
                        'serpDate',
                        'serpLink',
                      ),
                    ),
                  ),
                )
              ],
            ),
            // * REPLICA TEST IMAGE
            ListItemFactory.settingsItem(
              content: 'Replica - test image',
              trailingArray: [
                TextButton(
                  child: CText(
                    'Show'.toUpperCase(),
                    style: tsButton.copiedWith(color: Colors.deepOrangeAccent),
                  ),
                  onPressed: () async => await context.pushRoute(
                    ReplicaImageViewer(
                      replicaApi: replicaApi,
                      category: SearchCategory.Image,
                      item: ReplicaSearchItem(
                        'image test',
                        'png',
                        'humanizedLastModified',
                        'humanizedFileSize',
                        ReplicaLink.New(
                          'magnet%3A%3Fxt%3Durn%3Abtih%3Ae3cc2486d0875a07b82df20de98db7fab5e6371e%26xs%3Dreplica%3Ae3cc2486d0875a07b82df20de98db7fab5e6371e%26dn%3D1N_%40X%5B%604Z%5BF2K%40L%25J%402OYA2.png%26so%3D0',
                        )!,
                        'description',
                        'title',
                        'serpTitle',
                        'serpSnippet',
                        'serpSource',
                        'serpDate',
                        'serpLink',
                      ),
                    ),
                  ),
                )
              ],
            ),
            // * REPLICA SEARCH TERM
            ListItemFactory.settingsItem(
              content: 'Replica - current search term',
              trailingArray: [
                replicaModel.getSearchTermWidget(
                  (context, value, child) => CText(
                    value,
                    style: tsBody1.copiedWith(color: Colors.deepOrangeAccent),
                  ),
                )
              ],
            ),
            // * REPLICA SEARCH TAB
            ListItemFactory.settingsItem(
              content: 'Replica - current search tab',
              trailingArray: [
                replicaModel.getSearchTabWidget(
                  (context, value, child) => CText(
                    value,
                    style: tsBody1.copiedWith(color: Colors.deepOrangeAccent),
                  ),
                )
              ],
            ),
            // TODO <08-17-22, kalli> Not sure if this is doing what its supposed to do, fix
            // MarkdownBody(
            //   data:
            //       '''This is a markdown text blob. Only the links starting with replica:// count.
            //         replica://
            //           Nothing happens here: the link is empty

            //         hello world!
            //           Nothing happens here

            //         bunnyfoofooreplica://
            //           Nothing happens here

            //         replica://bunnyfoofoo
            //           This link counts

            //         replica://magnet:?xt=urn:btih:6a9759bffd5c0af65319979fb7832189f4f3c35d&dn=sintel.mp4
            //           This link counts

            //         replica://xt=urn:btih:6a9759bffd5c0af65319979fb7832189f4f3c35d&dn=sintel.mp4
            //           This link does not count since it has no leading 'magnet:?'

            //         magnet://xt=urn:btih:32729D0D089180D1095279069148DDC27323188B&dn=The%20Suicide%20Squad%20(2021)%20%5B1080p%5D%20%5BWEBRip%5D%20%5B5.1%5D%20&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2780%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&so=0
            //           This link does not count because it has the wrong prefix

            //         http://www.google.com
            //           This link does not count''',
            //   builders: {
            //     'replica': ReplicaLinkMarkdownElementBuilder(
            //       openLink: (replicaApi, replicaLink) {
            //         context.pushRoute(
            //           ReplicaLinkHandler(
            //             replicaApi: replicaApi,
            //             replicaLink: replicaLink,
            //           ),
            //         );
            //       },
            //     ),
            //   },
            //   extensionSet: md.ExtensionSet.gitHubFlavored,
            //   inlineSyntaxes: <md.InlineSyntax>[ReplicaLinkSyntax()],
            // ),
          ],
        ),
      );
    });
  }
}

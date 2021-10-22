import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

class ContactInfo extends StatelessWidget {
  final Contact contact;
  const ContactInfo({required this.contact}) : super();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      centerTitle: true,
      padHorizontal: false,
      title: contact.displayNameOrFallback,
      body: ListView(
        physics: defaultScrollPhysics,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*
                * Avatar
                */
                Container(
                  padding:
                      const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                  child: CustomAvatar(
                      messengerId: contact.contactId.id,
                      displayName: contact.displayNameOrFallback,
                      radius: 64),
                ),
                /*
                * Display Name - using Wrap since had issues with Row
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('display_name'.i18n.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    CListTile(
                      leading: const CAssetImage(
                        path: ImagePaths.user,
                      ),
                      content: CText(
                        contact.displayNameOrFallback,
                        style: tsSubtitle1Short,
                      ),
                      trailing: InkWell(
                        onTap: () {}, // TODO: Edit
                        child: Ink(
                          padding: const EdgeInsets.all(8),
                          child: CText(
                            'edit'.i18n.toUpperCase(),
                            style: tsButtonPink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                /*
                * Username
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('username'.i18n.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    CListTile(
                      leading: const CAssetImage(
                        path: ImagePaths.user,
                      ),
                      content: CText(
                        contact.displayNameOrFallback,
                        style: tsSubtitle1Short,
                      ),
                      trailing: InkWell(
                        onTap: () {}, // TODO: Copy
                        child: const CAssetImage(
                          path: ImagePaths.content_copy_outline,
                        ),
                      ),
                    ),
                  ],
                ),
                /*
                * Messenger ID
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('messenger_id'.i18n.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    CListTile(
                      leading: const CAssetImage(
                        path: ImagePaths.user,
                      ),
                      content: CText(
                        contact.contactId.id,
                        style: tsSubtitle1Short,
                      ),
                      trailing: InkWell(
                        onTap: () {}, // TODO: Copy
                        child: const Padding(
                          padding: EdgeInsetsDirectional.only(start: 10.0),
                          child: CAssetImage(
                            path: ImagePaths.content_copy_outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                /*
                * More Options
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('more_options'.i18n.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    CListTile(
                        leading: const CAssetImage(
                          path: ImagePaths.user,
                        ),
                        content: CText(
                          'block_user'.i18n,
                          style: tsSubtitle1Short,
                        ),
                        trailing: InkWell(
                          onTap: () {}, // TODO: Block
                          child: Ink(
                            padding: const EdgeInsets.all(8),
                            child: CText(
                              'block'.i18n.toUpperCase(),
                              style: tsButtonPink,
                            ),
                          ),
                        )),
                    const CDivider(),
                    CListTile(
                        leading: const CAssetImage(
                          path: ImagePaths.user,
                        ),
                        content: CText(
                          'delete_permanently'.i18n,
                          style: tsSubtitle1Short,
                        ),
                        trailing: InkWell(
                          onTap: () {}, // TODO: Delete
                          child: Ink(
                            padding: const EdgeInsets.all(8),
                            child: CText(
                              'delete'.i18n.toUpperCase(),
                              style: tsButtonPink,
                            ),
                          ),
                        )),
                  ],
                ),
                /*
                * BUTTON
                */
                Container(
                  padding:
                      const EdgeInsetsDirectional.only(top: 24, bottom: 32),
                  child: Button(
                    width: 200,
                    text: 'message'.i18n.toUpperCase(),
                    onPressed: () async {
                      context.loaderOverlay.show();
                      // try {
                      //   final name = displayNameController.value.text;
                      //   await messagingModel.setMyDisplayName(name);
                      //   Navigator.pop(context);
                      // } catch (e) {
                      //   displayNameController.error =
                      //       'display_name_invalid'.i18n;
                      // } finally {
                      //   context.loaderOverlay.hide();
                      // }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

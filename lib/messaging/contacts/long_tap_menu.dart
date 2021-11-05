import 'package:lantern/messaging/messaging.dart';

SizedBox renderLongTapMenu(
        {required Contact contact, required BuildContext context}) =>
    SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 4),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CListTile(
                leading: const CAssetImage(
                  path: ImagePaths.user,
                ),
                showDivider: false,
                content: 'view_contact_info'.i18n,
                onTap: () async {
                  await context.router.pop();
                  await context.pushRoute(ContactInfo(
                      model: context.watch<MessagingModel>(),
                      contact: contact));
                }),
            CListTile(
              leading: const CAssetImage(
                path: ImagePaths.people,
              ),
              showDivider: false,
              content: 'introduce_contacts'.i18n,
              onTap: () async {
                await context.router.pop();
                await context.pushRoute(const Introduce());
              },
            ),
          ],
        ),
      ),
    );

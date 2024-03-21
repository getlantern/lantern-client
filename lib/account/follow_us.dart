import '../common/common.dart';

enum _social {
  facebook,
  x,
  instagram,
  telegram,
}

class FollowUs extends StatelessWidget {
  const FollowUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 5),
          CText('follow_us'.i18n, style: tsHeading1),
          const SizedBox(height: 5),
          const CDivider(),
          ListItemFactory.settingsItem(
            icon: ImagePaths.thumbUp,
            content: 'follow_us_telegram'.i18n,
            height: 60,
            onTap: () => onSocialTap(_social.telegram),
          ),
          ListItemFactory.settingsItem(
            icon: ImagePaths.thumbUp,
            content: 'follow_us_x'.i18n,
            height: 60,
            onTap: () => onSocialTap(_social.x),
          ),
          ListItemFactory.settingsItem(
            icon: ImagePaths.thumbUp,
            content: 'follow_us_instagram'.i18n,
            height: 60,
            onTap: () => onSocialTap(_social.instagram),
          ),
          ListItemFactory.settingsItem(
            icon: ImagePaths.thumbUp,
            content: 'follow_us_facebook'.i18n,
            height: 60,
            onTap: () => onSocialTap(_social.facebook),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void onSocialTap(_social social) {
    switch (social) {
      case _social.facebook:
      // TODO: Handle this case.
      case _social.x:
      // TODO: Handle this case.
      case _social.instagram:
      // TODO: Handle this case.
      case _social.telegram:
      // TODO: Handle this case.
    }
  }
}

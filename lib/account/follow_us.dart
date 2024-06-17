import 'package:url_launcher/url_launcher.dart';

import '../common/common.dart';

enum _Social {
  facebook,
  x,
  instagram,
  telegram,
}

class FollowUs extends StatefulWidget {
  const FollowUs({super.key});

  @override
  State<FollowUs> createState() => _FollowUsState();
}

class _FollowUsState extends State<FollowUs> {
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
            icon: ImagePaths.telegram,
            content: 'follow_us_telegram'.i18n,
            height: 60,
            onTap: () => onSocialTap(_Social.telegram),
          ),
          ListItemFactory.settingsItem(
            icon: ImagePaths.x,
            content: 'follow_us_x'.i18n,
            height: 60,
            onTap: () => onSocialTap(_Social.x),
          ),
          ListItemFactory.settingsItem(
            icon: ImagePaths.instagram,
            content: 'follow_us_instagram'.i18n,
            height: 60,
            onTap: () => onSocialTap(_Social.instagram),
          ),
          ListItemFactory.settingsItem(
            icon: ImagePaths.facebook,
            content: 'follow_us_facebook'.i18n,
            height: 60,
            onTap: () => onSocialTap(_Social.facebook),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  final countryMap = {
    //Russia
    'ru': {
      _Social.facebook:
          'https://www.facebook.com/profile.php?id=61555417626781',
      _Social.x: 'https://twitter.com/Lantern_Russia',
      _Social.instagram: 'https://www.instagram.com/lantern.io_ru',
      _Social.telegram: 'https://t.me/lantern_russia',
    },
    //iran
    'ir': {
      _Social.facebook: 'https://www.facebook.com/getlanternpersian',
      _Social.x: 'https://twitter.com/getlantern_fa',
      _Social.instagram: 'https://www.instagram.com/getlantern_fa/',
      _Social.telegram: 'https://t.me/LanternFarsi',
    },
    //Ukraine
    'ua': {
      _Social.facebook:
          'https://www.facebook.com/profile.php?id=61554740875416',
      _Social.x: 'https://twitter.com/LanternUA',
      _Social.instagram: 'https://www.instagram.com/getlantern_ua/',
      _Social.telegram: 'https://t.me/lanternukraine',
    },
    //Belarus
    'by': {
      _Social.facebook:
          'https://www.facebook.com/profile.php?id=61554406268221',
      _Social.x: 'https://twitter.com/LanternBelarus',
      _Social.instagram: 'https://www.instagram.com/getlantern_belarus/',
      _Social.telegram: 'https://t.me/lantern_belarus',
    },
    //United Arab Emirates
    'uae': {
      _Social.facebook:
          'https://www.facebook.com/profile.php?id=61554655199439',
      _Social.x: 'https://twitter.com/getlantern_UAE',
      _Social.instagram: 'https://www.instagram.com/lanternio_uae/',
      _Social.telegram: 'https://t.me/lantern_uae',
    },
    //Guinea
    'gn': {
      _Social.facebook:
          'https://www.facebook.com/profile.php?id=61554620251833',
      _Social.x: 'https://twitter.com/getlantern_gu',
      _Social.instagram: 'https://www.instagram.com/lanternio_guinea/',
      _Social.telegram: 'https://t.me/LanternGuinea',
    },
    'all': {
      _Social.facebook: 'https://www.facebook.com/getlantern',
      _Social.x: 'https://twitter.com/getlantern',
      _Social.instagram: 'https://www.instagram.com/getlantern/',
      _Social.telegram: '',
    },
  };

  void onSocialTap(_Social social) {
    final countryCode = sessionModel.country.value ?? '';
    // Determine the social media map based on the country code,
    // defaulting to the 'all' map if no specific country is found
    final currentSocialMap = countryMap[countryCode] ?? countryMap['all']!;
    // Retrieve the URL for the selected social media platform
    final url = currentSocialMap[social]!;
    shareTap(Uri.parse(url));
  }

  Future<void> shareTap(Uri url) async {
    context.maybePop();
    if (url.hasEmptyPath) {
      showSnackbar(
          context: context,
          content:
              'We are currently experiencing technical difficulties with retrieving the link. Please try again later.',
          duration: const Duration(seconds: 2));
      return;
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

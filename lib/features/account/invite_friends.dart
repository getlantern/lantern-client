import 'package:lantern/core/utils/common.dart';
import 'package:share_plus/share_plus.dart';
@RoutePage(name: 'InviteFriends')
class InviteFriends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var referralCodeCopied = false;
    return BaseScreen(
      title: 'Invite Friends'.i18n,
      body: sessionModel.referralCode((BuildContext context,
              String referralCode, Widget? child) =>
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsetsDirectional.only(start: 4.0, end: 4.0),
              ),
              StatefulBuilder(
                  builder: (context, setState) => ListItemFactory.settingsItem(
                          header: 'referral_code'.i18n,
                          content: referralCode,
                          icon: ImagePaths.star,
                          onTap: () async {
                            copyText(context, referralCode);
                            setState(() => referralCodeCopied = true);
                            await Future.delayed(
                              defaultAnimationDuration,
                              () => setState(() => referralCodeCopied = false),
                            );
                          },
                          trailingArray: [
                            mirrorLTR(
                                context: context,
                                child: referralCodeCopied
                                    ? Icon(
                                        Icons.check_circle,
                                        color: indicatorGreen,
                                      )
                                    : Icon(
                                        Icons.file_copy,
                                        color: black,
                                      )),
                          ])),
              Container(
                padding: const EdgeInsetsDirectional.only(
                    top: 24, start: 12, end: 12),
                child: CText(
                  'share_lantern_pro'.i18n,
                  textAlign: TextAlign.justify,
                  style: tsBody2,
                ),
              ),
              const Spacer(),
              Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 56),
                  child: Button(
                    width: 200,
                    text: 'share_referral_code'.i18n,
                    onPressed: () async => await Share.share(
                        'share_message_referral_code'
                            .i18n
                            .fill([referralCode])),
                  )),
            ],
          )),
    );
  }
}

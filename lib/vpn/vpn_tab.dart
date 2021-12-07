import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';

import 'vpn_bandwidth.dart';
import 'vpn_pro_banner.dart';
import 'vpn_server_location.dart';
import 'vpn_status.dart';
import 'vpn_switch.dart';

class VPNTab extends StatelessWidget {
  VPNTab({Key? key}) : super(key: key);

  void _openInfoServerLocation(BuildContext context) {
    showInfoDialog(context,
        title: 'Server Location'.i18n,
        des: 'Server Location Info'.i18n,
        assetPath: ImagePaths.location_on,
        buttonText: 'OK'.i18n);
  }

  Widget renderVPN(SessionModel sessionModel) {
    return sessionModel
        .proUser((BuildContext context, bool proUser, Widget? child) {
      return BaseScreen(
        title: SvgPicture.asset(
          proUser ? ImagePaths.pro_logo : ImagePaths.free_logo,
          height: 16,
          fit: BoxFit.contain,
        ),
        padVertical: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            proUser ? Container() : ProBanner(),
            const ResetAllFlagsButton(),
            VPNSwitch(),
            Container(
              padding: const EdgeInsetsDirectional.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              ),
              child: Column(
                children: [
                  VPNStatus(),
                  Container(
                    child: const CDivider(height: 32.0),
                  ),
                  ServerLocationWidget(_openInfoServerLocation),
                  VPNBandwidth(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    var messagingModel = context.watch<MessagingModel>();

    return messagingModel.getFirstAccessedChatTS(
        (context, firstAccessedChatTS, child) => messagingModel
                .getFirstSeenIntroducingTS(
                    (context, firstSeenIntroducingTS, child) {
              // if we have never seen the Intro and we have never clicked on the Chat tab
              if (firstSeenIntroducingTS == 0 && firstAccessedChatTS == 0) {
                return renderIntroducing(context, messagingModel);
              }
              return renderVPN(sessionModel);
            }));
  }

  Widget renderIntroducing(
      BuildContext context, MessagingModel messagingModel) {
    final tsCustomButton = CTextStyle(
      fontSize: 14,
      lineHeight: 14,
      fontWeight: FontWeight.w500,
    );
    final tsDisplayItalic = CTextStyle(
      fontSize: 30,
      lineHeight: 36,
      color: white,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.italic,
    );
    return showFullscreenDialog(
      context: context,
      onCloseCallback: () async {
        await messagingModel.saveFirstSeenIntroducingTS();
        await context.router.pop();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsetsDirectional.only(bottom: 24),
              child: CAssetImage(
                path: ImagePaths.introducing_illustration,
                size: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              color: blue4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 32.0, bottom: 16.0),
                    child: CText('introducing'.i18n,
                        style: tsDisplayItalic, textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40.0, end: 40.0),
                    child: CText(
                      'introducing_des'.i18n,
                      style: tsBody1.copiedWith(color: white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40, end: 40, top: 36.0, bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () async {
                              await messagingModel.saveFirstSeenIntroducingTS();
                              await context.router.pop();
                            },
                            child: CText(
                              'maybe_later'.i18n.toUpperCase(),
                              style: tsCustomButton.copiedWith(color: white),
                            )),
                        TextButton(
                            onPressed: () async {
                              await messagingModel.saveFirstAccessedChatTS();
                              // TODO: switch to Chats tab
                            },
                            child: CText(
                              'try'.i18n.toUpperCase(),
                              style: tsCustomButton.copiedWith(color: yellow3),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

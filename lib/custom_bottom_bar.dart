import 'package:lantern/custom_bottom_item.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/replica/logic/common.dart';

class CustomBottomBar extends StatelessWidget {
  final int index;
  final Function(int)? onTap;
  final bool isDevelop;

  const CustomBottomBar(
      {required this.index,
      required this.isDevelop,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      elevation: 0.0,
      unselectedFontSize: 0,
      selectedFontSize: 0,
      showSelectedLabels: false,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: messagingModel.getFirstShownTryLanternChatModalTS(
              (context, ts, child) => NowBuilder(
                  calculate: (now) =>
                      (now.millisecondsSinceEpoch - ts) < oneWeekInMillis,
                  builder: (BuildContext context, bool badgeShowing) =>
                      CustomBottomBarItem(
                        currentIndex: index,
                        position: 0,
                        total: isDevelop ? 4 : 3,
                        label: CText('secure_chat'.i18n,
                            style: tsFloatingLabel.copiedWith(
                                color: index == 0 ? black : grey5)),
                        icon: CBadge(
                          showBadge: badgeShowing,
                          end: -20,
                          top: -10,
                          customBadge: Container(
                            padding: const EdgeInsetsDirectional.only(
                                top: 2.0, bottom: 2.0, start: 5.0, end: 5.0),
                            decoration: BoxDecoration(
                              color: blue3,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(80.0),
                              ),
                            ),
                            child: Text('new'.i18n.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: white,
                                )),
                          ),
                          child: NumUnviewedWrapper(index: index),
                        ),
                        onTap: () async {
                          onTap!(0);
                        },
                      ))),
          label: '',
          tooltip: 'chats'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomBarItem(
            currentIndex: index,
            position: 1,
            total: isDevelop ? 4 : 3,
            label: CText('VPN'.i18n,
                style: tsFloatingLabel.copiedWith(
                    color: index == 1 ? black : grey5)),
            icon: CAssetImage(
              path: ImagePaths.key,
              color: index == 1 ? selectedTabIconColor : unselectedTabIconColor,
            ),
            onTap: () => onTap!(1),
            iconWidget: vpnModel.vpnStatus(
              (context, value, child) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 4.0),
                child: CircleAvatar(
                  maxRadius: activeIconSize - 4,
                  backgroundColor: (value.toLowerCase() ==
                              'Disconnecting'.i18n.toLowerCase() ||
                          value == 'connected'.i18n.toLowerCase())
                      ? indicatorGreen
                      : indicatorRed,
                ),
              ),
            ),
          ),
          label: '',
          tooltip: 'VPN'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomBarItem(
            currentIndex: index,
            position: 2,
            total: isDevelop ? 4 : 3,
            label: CText('Account'.i18n,
                style: tsFloatingLabel.copiedWith(
                    color: index == 2 ? black : grey5)),
            onTap: () => onTap!(2),
            icon: messagingModel.getOnBoardingStatus(
                (context, hasBeenOnboarded, child) => hasBeenOnboarded == true
                    ? messagingModel.getCopiedRecoveryStatus(
                        (context, hasCopiedRecoveryKey, child) => CBadge(
                              count: 1,
                              showBadge: !hasCopiedRecoveryKey,
                              child: CAssetImage(
                                path: ImagePaths.account,
                                color: index == 2
                                    ? selectedTabIconColor
                                    : unselectedTabIconColor,
                              ),
                            ))
                    : CAssetImage(
                        path: ImagePaths.account,
                        color: index == 2
                            ? selectedTabIconColor
                            : unselectedTabIconColor,
                      )),
          ),
          label: '',
          tooltip: 'Account'.i18n,
        ),
        if (ReplicaCommon.isReplicaRunning())
          BottomNavigationBarItem(
            icon: CustomBottomBarItem(
              currentIndex: index,
              position: 3,
              total: isDevelop ? 4 : 3,
              label: CText('Discover'.i18n,
                  style: tsFloatingLabel.copiedWith(
                      color: index == 3 ? black : grey5)),
              icon: CAssetImage(
                path: ImagePaths.discover,
                color:
                    index == 3 ? selectedTabIconColor : unselectedTabIconColor,
              ),
              onTap: () => onTap!(3),
            ),
            label: '',
            tooltip: 'Discover'.i18n,
          ),
        if (isDevelop)
          BottomNavigationBarItem(
            icon: CustomBottomBarItem(
              currentIndex: index,
              position: 4,
              total: isDevelop ? 4 : 3,
              label: CText('Developer'.i18n,
                  style: tsFloatingLabel.copiedWith(
                      color: index == 4 ? black : grey5)),
              icon: CAssetImage(
                path: ImagePaths.devices,
                color:
                    index == 4 ? selectedTabIconColor : unselectedTabIconColor,
              ),
              onTap: () => onTap!(4),
            ),
            label: '',
            tooltip: 'Developer'.i18n,
          ),
      ],
    );
  }
}

class NumUnviewedWrapper extends StatelessWidget {
  const NumUnviewedWrapper({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    // iterate over contacts by activity (most recent conversations)
    return messagingModel.contactsByActivity(builder:
        (context, Iterable<PathAndValue<Contact>> contacts, Widget? child) {
      final totalUnviewed = contacts.isNotEmpty
          ? contacts
              .map(
                  (e) => e.value.isAccepted() ? e.value.numUnviewedMessages : 0)
              .reduce((value, element) => value + element)
          : 0;
      return CBadge(
        showBadge: totalUnviewed > 0,
        count: totalUnviewed,
        child: CAssetImage(
          path: ImagePaths.messages,
          color: index == 0 ? selectedTabIconColor : unselectedTabIconColor,
        ),
      );
    });
  }
}

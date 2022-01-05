import 'package:lantern/custom_bottom_item.dart';
import 'package:lantern/messaging/messaging.dart';

class CustomBottomBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  final bool isDevelop;

  const CustomBottomBar({
    required this.index,
    required this.isDevelop,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalTabs = isDevelop ? 4 : 3;

    return messagingModel.getOnBoardingStatus(
      (context, hasBeenOnboarded, child) => BottomNavigationBar(
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
              (context, ts, _) => NowBuilder(
                calculate: (now) =>
                    hasBeenOnboarded != true &&
                    (now.millisecondsSinceEpoch - ts) < oneWeekInMillis,
                builder: (BuildContext context, bool showNewBadge) =>
                    CustomBottomBarItem(
                  currentTabIndex: index,
                  tabIndex: 0,
                  total: totalTabs,
                  label: 'chats'.i18n,
                  icon: ImagePaths.messages,
                  onTap: onTap,
                  addBadge: (child) {
                    if (!showNewBadge) {
                      return messagingModel.contactsByActivity(
                        builder: (
                          context,
                          Iterable<PathAndValue<Contact>> contacts,
                          Widget? _,
                        ) {
                          final totalUnviewed = contacts.isNotEmpty
                              ? contacts
                                  .map(
                                    (e) => e.value.isAccepted()
                                        ? e.value.numUnviewedMessages
                                        : 0,
                                  )
                                  .reduce((value, element) => value + element)
                              : 0;
                          return CBadge(
                            showBadge: totalUnviewed > 0,
                            count: totalUnviewed,
                            child: child,
                          );
                        },
                      );
                    }

                    return CBadge(
                      end: -20,
                      top: -10,
                      showBadge: true,
                      customBadge: Container(
                        padding: const EdgeInsetsDirectional.only(
                          top: 2.0,
                          bottom: 2.0,
                          start: 5.0,
                          end: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: blue3,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(80.0),
                          ),
                        ),
                        child: Text(
                          'new'.i18n.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: white,
                          ),
                        ),
                      ),
                      child: child,
                    );
                  },
                ),
              ),
            ),
            label: '',
            tooltip: 'chats'.i18n,
          ),
          BottomNavigationBarItem(
            icon: CustomBottomBarItem(
              currentTabIndex: index,
              tabIndex: 1,
              total: totalTabs,
              label: 'VPN'.i18n,
              icon: ImagePaths.key,
              onTap: onTap,
              labelWidget: vpnModel.vpnStatus(
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
            icon: sessionModel.replicaAddr((context, replicaAddr, child) {
              final replicaEnabled = replicaAddr != '';
              return CustomBottomBarItem(
                currentTabIndex: index,
                tabIndex: 2,
                total: totalTabs,
                label: 'discover'.i18n,
                icon: ImagePaths.discover,
                disabled: !replicaEnabled,
                onTap: onTap,
              );
            }),
            label: '',
            tooltip: 'discover'.i18n,
          ),
          BottomNavigationBarItem(
            icon: CustomBottomBarItem(
              currentTabIndex: index,
              tabIndex: 3,
              total: totalTabs,
              label: 'Account'.i18n,
              onTap: onTap,
              icon: ImagePaths.account,
              addBadge: (child) {
                if (hasBeenOnboarded != true) {
                  return child;
                }

                return messagingModel.getCopiedRecoveryStatus(
                  (context, hasCopiedRecoveryKey, _) => CBadge(
                    count: 1,
                    showBadge: !hasCopiedRecoveryKey,
                    child: child,
                  ),
                );
              },
            ),
            label: '',
            tooltip: 'Account'.i18n,
          ),
          if (isDevelop)
            BottomNavigationBarItem(
              icon: CustomBottomBarItem(
                currentTabIndex: index,
                tabIndex: 4,
                total: totalTabs,
                label: 'Developer'.i18n,
                icon: ImagePaths.devices,
                onTap: onTap,
              ),
              label: '',
              tooltip: 'Developer'.i18n,
            ),
        ],
      ),
    );
  }
}

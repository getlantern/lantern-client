import 'package:lantern/custom_bottom_item.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/replica/common.dart';

class CustomBottomBar extends StatelessWidget {
  final String selectedTab;
  final bool isDevelop;
  final bool isTesting;

  const CustomBottomBar({
    required this.selectedTab,
    required this.isDevelop,
    this.isTesting = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sessionModel.chatEnabled((context, chatEnabled, _) {
        return sessionModel.replicaAddr((context, replicaAddr, child) {
          final replicaEnabled = replicaAddr != '';

          final indexToTab = <int, String>{};
          final tabToIndex = <String, int>{};

          var nextIndex = 0;
          if (chatEnabled) {
            indexToTab[nextIndex] = TAB_CHATS;
            tabToIndex[TAB_CHATS] = nextIndex++;
          }
          indexToTab[nextIndex] = TAB_VPN;
          tabToIndex[TAB_VPN] = nextIndex++;
          if (replicaEnabled) {
            indexToTab[nextIndex] = TAB_REPLICA;
            tabToIndex[TAB_REPLICA] = nextIndex++;
          }
          indexToTab[nextIndex] = TAB_ACCOUNT;
          tabToIndex[TAB_ACCOUNT] = nextIndex++;
          if (isDevelop && !isTesting) {
            indexToTab[nextIndex] = TAB_DEVELOPER;
            tabToIndex[TAB_DEVELOPER] = nextIndex++;
          }

          final currentIndex = tabToIndex[selectedTab] ?? tabToIndex[TAB_VPN]!;
          return BottomNavigationBar(
            currentIndex: currentIndex,
            elevation: 0.0,
            unselectedFontSize: 0,
            selectedFontSize: 0,
            showSelectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: buildItems(
              indexToTab,
              tabToIndex,
              currentIndex,
              chatEnabled,
              replicaEnabled,
              true,
              isDevelop,
              isTesting,
              replicaAddr,
            ),
          );
        });
    });
  }

  List<BottomNavigationBarItem> buildItems(
    Map<int, String> indexToTab,
    Map<String, int> tabToIndex,
    int currentIndex,
    bool chatEnabled,
    bool replicaEnabled,
    bool hasBeenOnboarded,
    bool isDevelop,
    bool isTesting,
    String replicaAddr,
  ) {
    final items = <BottomNavigationBarItem>[];
    if (chatEnabled) {
      items.add(
        BottomNavigationBarItem(
          icon: messagingModel.getFirstShownTryLanternChatModalTS(
            (context, ts, _) => NowBuilder(
              calculate: (now) =>
                  hasBeenOnboarded != true &&
                  (now.millisecondsSinceEpoch - ts) < oneWeekInMillis,
              builder: (BuildContext context, bool showNewBadge) =>
                  CustomBottomBarItem(
                name: TAB_CHATS,
                currentTabIndex: currentIndex,
                indexToTab: indexToTab,
                tabToIndex: tabToIndex,
                label: 'chats'.i18n,
                icon: ImagePaths.messages,
                addBadge: (child) {
                  if (!chatEnabled || !showNewBadge) {
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
                    top: -5,
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
      );
    }

    items.add(
      BottomNavigationBarItem(
        icon: CustomBottomBarItem(
          name: TAB_VPN,
          currentTabIndex: currentIndex,
          indexToTab: indexToTab,
          tabToIndex: tabToIndex,
          label: 'VPN'.i18n,
          icon: ImagePaths.key,
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
    );

    if (replicaEnabled) {
      items.add(
        BottomNavigationBarItem(
          icon: replicaModel.getShowNewBadgeWidget(
            (context, showNewBadge, child) => CustomBottomBarItem(
              name: TAB_REPLICA,
              currentTabIndex: currentIndex,
              indexToTab: indexToTab,
              tabToIndex: tabToIndex,
              label: 'discover'.i18n,
              icon: ImagePaths.discover,
              addBadge: (child) {
                if (showNewBadge) {
                  return CBadge(
                    end: -20,
                    top: -5,
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
                } else {
                  return CBadge(child: child);
                }
              },
            ),
          ),
          label: '',
          tooltip: 'discover'.i18n,
        ),
      );
    }

    items.add(
      BottomNavigationBarItem(
        icon: CustomBottomBarItem(
          key: AppKeys.bottom_bar_account_tap_key,
          name: TAB_ACCOUNT,
          currentTabIndex: currentIndex,
          indexToTab: indexToTab,
          tabToIndex: tabToIndex,
          label: 'Account'.i18n,
          icon: ImagePaths.account,
          addBadge: (child) {
            if (hasBeenOnboarded == true) {
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
    );

    if (isDevelop && !isTesting) {
      items.add(
        BottomNavigationBarItem(
          icon: CustomBottomBarItem(
            key: AppKeys.bottom_bar_developer_tap_key,
            name: TAB_DEVELOPER,
            currentTabIndex: currentIndex,
            indexToTab: indexToTab,
            tabToIndex: tabToIndex,
            label: 'Developer'.i18n,
            icon: ImagePaths.devices,
          ),
          label: '',
          tooltip: 'Developer'.i18n,
        ),
      );
    }

    return items;
  }
}

///Change notifier used the bottom bar
///update tap when user click on the bottom bar
class BottomBarChangeNotifier extends ChangeNotifier {
  String _currentIndex = TAB_VPN;

  String get currentIndex => _currentIndex;

  void setCurrentIndex(String tabName) {
    _currentIndex = tabName;
    notifyListeners();
  }
}

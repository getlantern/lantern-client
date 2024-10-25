import 'package:flutter/foundation.dart';

class AppKeys {
  //Bottom Bar Key
  static const bottom_bar_developer_tap_key =
      ValueKey('bottomBar_developer_tap');
  static const bottom_bar_account_tap_key = ValueKey('bottomBar_account_tap');

  //Developer Widget
  static const payment_mode_switch = ValueKey('payment_mode_switch');

  //Account Widget
  static const upgrade_lantern_pro = ValueKey('upgrade_lantern_pro');
  static const inviteFriends = ValueKey('invite_friends');
  static const devices = ValueKey('devices');
  static const signIn = ValueKey('sign_in');
  static const desktopVersion = ValueKey('desktop_version');
  static const followUs = ValueKey('follow_us');
  static const setting = ValueKey('setting');
  static const signOut = ValueKey('sign_out');

  static const account_management = ValueKey('account_management');
  static const account_renew = ValueKey('account_renew');
  static const support = ValueKey('support');

  //Plans
  static const plan_list_view = ValueKey('plan_list_view');
  static const mostPopular = ValueKey('most_popular');

  //Checkout
  static const continueCheckout = 'checkout';
  static const cardNumberKey = 'card_number';
  static const mmYYKey = 'mm_yy';
  static const cvcKey = 'cvc';
  static const checkOut = 'check_out';
  static const renewalSuccessOk = 'renew_success_ok';

  //Support
  static const reportIssue = ValueKey('report_issue');
  static const userForum = ValueKey('lantern_user_forum');
  static const faq = ValueKey('faq');
  static const reportDescription = 'report_description';
  static const sendReport = 'send_report';

  //Settings
  static const language = ValueKey('language');
  static const checkForUpdates = ValueKey('check_for_updates');
  static const splitTunneling = ValueKey('split_tunnel');
  static const privacyPolicy = ValueKey('privacy_policy');
  static const termsOfServices = ValueKey('terms_of_services');
  static const proxyAll = ValueKey('proxy_all');
  static const proxySetting = ValueKey('proxy_setting');
  static const chat = ValueKey('chat');

  // Proxies setting
  static const httpProxy = ValueKey('http_proxy');
  static const socksProxy = ValueKey('socks_proxy');

}


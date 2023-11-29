// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i50;

import 'package:auto_route/auto_route.dart' as _i46;
import 'package:flutter/cupertino.dart' as _i51;
import 'package:lantern/account/account.dart' as _i2;
import 'package:lantern/account/account_management.dart' as _i1;
import 'package:lantern/account/auth/confirm_email.dart' as _i14;
import 'package:lantern/account/auth/create_password.dart' as _i17;
import 'package:lantern/account/auth/reset_password.dart' as _i39;
import 'package:lantern/account/auth/sign_in.dart' as _i41;
import 'package:lantern/account/auth/verification.dart' as _i45;
import 'package:lantern/account/blocked_users.dart' as _i9;
import 'package:lantern/account/chat_number_account.dart' as _i10;
import 'package:lantern/account/device_linking/approve_device.dart' as _i5;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i6;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i7;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i8;
import 'package:lantern/account/device_linking/link_device.dart' as _i25;
import 'package:lantern/account/invite_friends.dart' as _i22;
import 'package:lantern/account/language.dart' as _i23;
import 'package:lantern/account/lantern_desktop.dart' as _i24;
import 'package:lantern/account/recovery_key.dart' as _i28;
import 'package:lantern/account/report_issue.dart' as _i37;
import 'package:lantern/account/settings.dart' as _i40;
import 'package:lantern/account/split_tunneling.dart' as _i42;
import 'package:lantern/account/support.dart' as _i44;
import 'package:lantern/common/common.dart' as _i48;
import 'package:lantern/common/ui/app_webview.dart' as _i4;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i18;
import 'package:lantern/home.dart' as _i19;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i3;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i15;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i26;
import 'package:lantern/messaging/conversation/conversation.dart' as _i16;
import 'package:lantern/messaging/introductions/introduce.dart' as _i20;
import 'package:lantern/messaging/introductions/introductions.dart' as _i21;
import 'package:lantern/messaging/messaging.dart' as _i47;
import 'package:lantern/messaging/onboarding/chat_number_messaging.dart'
    as _i11;
import 'package:lantern/messaging/onboarding/chat_number_recovery.dart' as _i12;
import 'package:lantern/plans/checkout.dart' as _i13;
import 'package:lantern/plans/plans.dart' as _i27;
import 'package:lantern/plans/reseller_checkout.dart' as _i38;
import 'package:lantern/plans/stripe_checkout.dart' as _i43;
import 'package:lantern/replica/common.dart' as _i49;
import 'package:lantern/replica/link_handler.dart' as _i31;
import 'package:lantern/replica/ui/viewers/audio.dart' as _i29;
import 'package:lantern/replica/ui/viewers/image.dart' as _i30;
import 'package:lantern/replica/ui/viewers/misc.dart' as _i32;
import 'package:lantern/replica/ui/viewers/video.dart' as _i36;
import 'package:lantern/replica/upload/description.dart' as _i33;
import 'package:lantern/replica/upload/review.dart' as _i34;
import 'package:lantern/replica/upload/title.dart' as _i35;

abstract class $AppRouter extends _i46.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i46.PageFactory> pagesMap = {
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i1.AccountManagement(
          key: args.key,
          isPro: args.isPro,
        ),
      );
    },
    Account.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i2.AccountMenu(),
      );
    },
    AddViaChatNumber.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i3.AddViaChatNumber(),
      );
    },
    AppWebview.name: (routeData) {
      final args = routeData.argsAs<AppWebviewArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.AppWebView(
          key: args.key,
          url: args.url,
        ),
      );
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i5.ApproveDevice(key: args.key),
      );
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i6.AuthorizeDeviceForPro(key: args.key),
      );
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i7.AuthorizeDeviceViaEmail(key: args.key),
      );
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i8.AuthorizeDeviceViaEmailPin(key: args.key),
      );
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i9.BlockedUsers(key: args.key),
      );
    },
    ChatNumberAccount.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i10.ChatNumberAccount(),
      );
    },
    ChatNumberMessaging.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i11.ChatNumberMessaging(),
      );
    },
    ChatNumberRecovery.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i12.ChatNumberRecovery(),
      );
    },
    Checkout.name: (routeData) {
      final args = routeData.argsAs<CheckoutArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.Checkout(
          plan: args.plan,
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    ConfirmEmail.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i14.ConfirmEmail(),
      );
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i15.ContactInfo(contact: args.contact),
      );
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i16.Conversation(
          contactId: args.contactId,
          initialScrollIndex: args.initialScrollIndex,
          showContactEditingDialog: args.showContactEditingDialog,
        ),
      );
    },
    CreatePassword.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i17.CreatePassword(),
      );
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i18.FullScreenDialog(
          widget: args.widget,
          key: args.key,
        ),
      );
    },
    Home.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i19.HomePage(),
      );
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i20.Introduce(
          singleIntro: args.singleIntro,
          contactToIntro: args.contactToIntro,
        ),
      );
    },
    Introductions.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i21.Introductions(),
      );
    },
    InviteFriends.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i22.InviteFriends(),
      );
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i23.Language(key: args.key),
      );
    },
    LanternDesktop.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i24.LanternDesktop(),
      );
    },
    LinkDevice.name: (routeData) {
      final args = routeData.argsAs<LinkDeviceArgs>(
          orElse: () => const LinkDeviceArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i25.LinkDevice(key: args.key),
      );
    },
    NewChat.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i26.NewChat(),
      );
    },
    PlansPage.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i27.PlansPage(),
      );
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i28.RecoveryKey(key: args.key),
      );
    },
    ReplicaAudioViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaAudioViewerArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i29.ReplicaAudioViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaImageViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaImageViewerArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i30.ReplicaImageViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaLinkHandler.name: (routeData) {
      final args = routeData.argsAs<ReplicaLinkHandlerArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i31.ReplicaLinkHandler(
          key: args.key,
          replicaApi: args.replicaApi,
          replicaLink: args.replicaLink,
        ),
      );
    },
    ReplicaMiscViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaMiscViewerArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i32.ReplicaMiscViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaUploadDescription.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadDescriptionArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i33.ReplicaUploadDescription(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadReview.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadReviewArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i34.ReplicaUploadReview(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadTitle.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadTitleArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i35.ReplicaUploadTitle(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaVideoViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaVideoViewerArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i36.ReplicaVideoViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReportIssue.name: (routeData) {
      final args = routeData.argsAs<ReportIssueArgs>(
          orElse: () => const ReportIssueArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i37.ReportIssue(key: args.key),
      );
    },
    ResellerCodeCheckout.name: (routeData) {
      final args = routeData.argsAs<ResellerCodeCheckoutArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i38.ResellerCodeCheckout(
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    ResetPassword.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i39.ResetPassword(),
      );
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i40.Settings(key: args.key),
      );
    },
    SignIn.name: (routeData) {
      final args =
          routeData.argsAs<SignInArgs>(orElse: () => const SignInArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i41.SignIn(
          key: args.key,
          resetPasswordFlow: args.resetPasswordFlow,
        ),
      );
    },
    SplitTunneling.name: (routeData) {
      final args = routeData.argsAs<SplitTunnelingArgs>(
          orElse: () => const SplitTunnelingArgs());
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i42.SplitTunneling(key: args.key),
      );
    },
    StripeCheckout.name: (routeData) {
      final args = routeData.argsAs<StripeCheckoutArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i43.StripeCheckout(
          plan: args.plan,
          email: args.email,
          refCode: args.refCode,
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    Support.name: (routeData) {
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i44.Support(),
      );
    },
    Verification.name: (routeData) {
      final args = routeData.argsAs<VerificationArgs>();
      return _i46.AutoRoutePage<void>(
        routeData: routeData,
        child: _i45.Verification(
          key: args.key,
          email: args.email,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.AccountManagement]
class AccountManagement extends _i46.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({
    _i47.Key? key,
    required bool isPro,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          AccountManagement.name,
          args: AccountManagementArgs(
            key: key,
            isPro: isPro,
          ),
          initialChildren: children,
        );

  static const String name = 'AccountManagement';

  static const _i46.PageInfo<AccountManagementArgs> page =
      _i46.PageInfo<AccountManagementArgs>(name);
}

class AccountManagementArgs {
  const AccountManagementArgs({
    this.key,
    required this.isPro,
  });

  final _i47.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for
/// [_i2.AccountMenu]
class Account extends _i46.PageRouteInfo<void> {
  const Account({List<_i46.PageRouteInfo>? children})
      : super(
          Account.name,
          initialChildren: children,
        );

  static const String name = 'Account';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i3.AddViaChatNumber]
class AddViaChatNumber extends _i46.PageRouteInfo<void> {
  const AddViaChatNumber({List<_i46.PageRouteInfo>? children})
      : super(
          AddViaChatNumber.name,
          initialChildren: children,
        );

  static const String name = 'AddViaChatNumber';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i4.AppWebView]
class AppWebview extends _i46.PageRouteInfo<AppWebviewArgs> {
  AppWebview({
    _i48.Key? key,
    required String url,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          AppWebview.name,
          args: AppWebviewArgs(
            key: key,
            url: url,
          ),
          initialChildren: children,
        );

  static const String name = 'AppWebview';

  static const _i46.PageInfo<AppWebviewArgs> page =
      _i46.PageInfo<AppWebviewArgs>(name);
}

class AppWebviewArgs {
  const AppWebviewArgs({
    this.key,
    required this.url,
  });

  final _i48.Key? key;

  final String url;

  @override
  String toString() {
    return 'AppWebviewArgs{key: $key, url: $url}';
  }
}

/// generated route for
/// [_i5.ApproveDevice]
class ApproveDevice extends _i46.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ApproveDevice.name,
          args: ApproveDeviceArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ApproveDevice';

  static const _i46.PageInfo<ApproveDeviceArgs> page =
      _i46.PageInfo<ApproveDeviceArgs>(name);
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'ApproveDeviceArgs{key: $key}';
  }
}

/// generated route for
/// [_i6.AuthorizeDeviceForPro]
class AuthorizePro extends _i46.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          AuthorizePro.name,
          args: AuthorizeProArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizePro';

  static const _i46.PageInfo<AuthorizeProArgs> page =
      _i46.PageInfo<AuthorizeProArgs>(name);
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'AuthorizeProArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i46.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmail.name,
          args: AuthorizeDeviceEmailArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmail';

  static const _i46.PageInfo<AuthorizeDeviceEmailArgs> page =
      _i46.PageInfo<AuthorizeDeviceEmailArgs>(name);
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailArgs{key: $key}';
  }
}

/// generated route for
/// [_i8.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i46.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmailPin.name,
          args: AuthorizeDeviceEmailPinArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmailPin';

  static const _i46.PageInfo<AuthorizeDeviceEmailPinArgs> page =
      _i46.PageInfo<AuthorizeDeviceEmailPinArgs>(name);
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailPinArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.BlockedUsers]
class BlockedUsers extends _i46.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({
    _i47.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          BlockedUsers.name,
          args: BlockedUsersArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'BlockedUsers';

  static const _i46.PageInfo<BlockedUsersArgs> page =
      _i46.PageInfo<BlockedUsersArgs>(name);
}

class BlockedUsersArgs {
  const BlockedUsersArgs({this.key});

  final _i47.Key? key;

  @override
  String toString() {
    return 'BlockedUsersArgs{key: $key}';
  }
}

/// generated route for
/// [_i10.ChatNumberAccount]
class ChatNumberAccount extends _i46.PageRouteInfo<void> {
  const ChatNumberAccount({List<_i46.PageRouteInfo>? children})
      : super(
          ChatNumberAccount.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberAccount';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i11.ChatNumberMessaging]
class ChatNumberMessaging extends _i46.PageRouteInfo<void> {
  const ChatNumberMessaging({List<_i46.PageRouteInfo>? children})
      : super(
          ChatNumberMessaging.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberMessaging';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i12.ChatNumberRecovery]
class ChatNumberRecovery extends _i46.PageRouteInfo<void> {
  const ChatNumberRecovery({List<_i46.PageRouteInfo>? children})
      : super(
          ChatNumberRecovery.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberRecovery';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i13.Checkout]
class Checkout extends _i46.PageRouteInfo<CheckoutArgs> {
  Checkout({
    required _i48.Plan plan,
    required bool isPro,
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          Checkout.name,
          args: CheckoutArgs(
            plan: plan,
            isPro: isPro,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'Checkout';

  static const _i46.PageInfo<CheckoutArgs> page =
      _i46.PageInfo<CheckoutArgs>(name);
}

class CheckoutArgs {
  const CheckoutArgs({
    required this.plan,
    required this.isPro,
    this.key,
  });

  final _i48.Plan plan;

  final bool isPro;

  final _i48.Key? key;

  @override
  String toString() {
    return 'CheckoutArgs{plan: $plan, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i14.ConfirmEmail]
class ConfirmEmail extends _i46.PageRouteInfo<void> {
  const ConfirmEmail({List<_i46.PageRouteInfo>? children})
      : super(
          ConfirmEmail.name,
          initialChildren: children,
        );

  static const String name = 'ConfirmEmail';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i15.ContactInfo]
class ContactInfo extends _i46.PageRouteInfo<ContactInfoArgs> {
  ContactInfo({
    required _i47.Contact contact,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ContactInfo.name,
          args: ContactInfoArgs(contact: contact),
          initialChildren: children,
        );

  static const String name = 'ContactInfo';

  static const _i46.PageInfo<ContactInfoArgs> page =
      _i46.PageInfo<ContactInfoArgs>(name);
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.contact});

  final _i47.Contact contact;

  @override
  String toString() {
    return 'ContactInfoArgs{contact: $contact}';
  }
}

/// generated route for
/// [_i16.Conversation]
class Conversation extends _i46.PageRouteInfo<ConversationArgs> {
  Conversation({
    required _i47.ContactId contactId,
    int? initialScrollIndex,
    bool showContactEditingDialog = false,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          Conversation.name,
          args: ConversationArgs(
            contactId: contactId,
            initialScrollIndex: initialScrollIndex,
            showContactEditingDialog: showContactEditingDialog,
          ),
          initialChildren: children,
        );

  static const String name = 'Conversation';

  static const _i46.PageInfo<ConversationArgs> page =
      _i46.PageInfo<ConversationArgs>(name);
}

class ConversationArgs {
  const ConversationArgs({
    required this.contactId,
    this.initialScrollIndex,
    this.showContactEditingDialog = false,
  });

  final _i47.ContactId contactId;

  final int? initialScrollIndex;

  final bool showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

/// generated route for
/// [_i17.CreatePassword]
class CreatePassword extends _i46.PageRouteInfo<void> {
  const CreatePassword({List<_i46.PageRouteInfo>? children})
      : super(
          CreatePassword.name,
          initialChildren: children,
        );

  static const String name = 'CreatePassword';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i18.FullScreenDialog]
class FullScreenDialogPage
    extends _i46.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({
    required _i48.Widget widget,
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          FullScreenDialogPage.name,
          args: FullScreenDialogPageArgs(
            widget: widget,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'FullScreenDialogPage';

  static const _i46.PageInfo<FullScreenDialogPageArgs> page =
      _i46.PageInfo<FullScreenDialogPageArgs>(name);
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({
    required this.widget,
    this.key,
  });

  final _i48.Widget widget;

  final _i48.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for
/// [_i19.HomePage]
class Home extends _i46.PageRouteInfo<void> {
  const Home({List<_i46.PageRouteInfo>? children})
      : super(
          Home.name,
          initialChildren: children,
        );

  static const String name = 'Home';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i20.Introduce]
class Introduce extends _i46.PageRouteInfo<IntroduceArgs> {
  Introduce({
    required bool singleIntro,
    _i47.Contact? contactToIntro,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          Introduce.name,
          args: IntroduceArgs(
            singleIntro: singleIntro,
            contactToIntro: contactToIntro,
          ),
          initialChildren: children,
        );

  static const String name = 'Introduce';

  static const _i46.PageInfo<IntroduceArgs> page =
      _i46.PageInfo<IntroduceArgs>(name);
}

class IntroduceArgs {
  const IntroduceArgs({
    required this.singleIntro,
    this.contactToIntro,
  });

  final bool singleIntro;

  final _i47.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for
/// [_i21.Introductions]
class Introductions extends _i46.PageRouteInfo<void> {
  const Introductions({List<_i46.PageRouteInfo>? children})
      : super(
          Introductions.name,
          initialChildren: children,
        );

  static const String name = 'Introductions';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i22.InviteFriends]
class InviteFriends extends _i46.PageRouteInfo<void> {
  const InviteFriends({List<_i46.PageRouteInfo>? children})
      : super(
          InviteFriends.name,
          initialChildren: children,
        );

  static const String name = 'InviteFriends';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i23.Language]
class Language extends _i46.PageRouteInfo<LanguageArgs> {
  Language({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          Language.name,
          args: LanguageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Language';

  static const _i46.PageInfo<LanguageArgs> page =
      _i46.PageInfo<LanguageArgs>(name);
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'LanguageArgs{key: $key}';
  }
}

/// generated route for
/// [_i24.LanternDesktop]
class LanternDesktop extends _i46.PageRouteInfo<void> {
  const LanternDesktop({List<_i46.PageRouteInfo>? children})
      : super(
          LanternDesktop.name,
          initialChildren: children,
        );

  static const String name = 'LanternDesktop';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i25.LinkDevice]
class LinkDevice extends _i46.PageRouteInfo<LinkDeviceArgs> {
  LinkDevice({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          LinkDevice.name,
          args: LinkDeviceArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'LinkDevice';

  static const _i46.PageInfo<LinkDeviceArgs> page =
      _i46.PageInfo<LinkDeviceArgs>(name);
}

class LinkDeviceArgs {
  const LinkDeviceArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'LinkDeviceArgs{key: $key}';
  }
}

/// generated route for
/// [_i26.NewChat]
class NewChat extends _i46.PageRouteInfo<void> {
  const NewChat({List<_i46.PageRouteInfo>? children})
      : super(
          NewChat.name,
          initialChildren: children,
        );

  static const String name = 'NewChat';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i27.PlansPage]
class PlansPage extends _i46.PageRouteInfo<void> {
  const PlansPage({List<_i46.PageRouteInfo>? children})
      : super(
          PlansPage.name,
          initialChildren: children,
        );

  static const String name = 'PlansPage';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i28.RecoveryKey]
class RecoveryKey extends _i46.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({
    _i47.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          RecoveryKey.name,
          args: RecoveryKeyArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RecoveryKey';

  static const _i46.PageInfo<RecoveryKeyArgs> page =
      _i46.PageInfo<RecoveryKeyArgs>(name);
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i47.Key? key;

  @override
  String toString() {
    return 'RecoveryKeyArgs{key: $key}';
  }
}

/// generated route for
/// [_i29.ReplicaAudioViewer]
class ReplicaAudioViewer extends _i46.PageRouteInfo<ReplicaAudioViewerArgs> {
  ReplicaAudioViewer({
    required _i49.ReplicaApi replicaApi,
    required _i49.ReplicaSearchItem item,
    required _i49.SearchCategory category,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaAudioViewer.name,
          args: ReplicaAudioViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaAudioViewer';

  static const _i46.PageInfo<ReplicaAudioViewerArgs> page =
      _i46.PageInfo<ReplicaAudioViewerArgs>(name);
}

class ReplicaAudioViewerArgs {
  const ReplicaAudioViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i49.ReplicaApi replicaApi;

  final _i49.ReplicaSearchItem item;

  final _i49.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaAudioViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i30.ReplicaImageViewer]
class ReplicaImageViewer extends _i46.PageRouteInfo<ReplicaImageViewerArgs> {
  ReplicaImageViewer({
    required _i49.ReplicaApi replicaApi,
    required _i49.ReplicaSearchItem item,
    required _i49.SearchCategory category,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaImageViewer.name,
          args: ReplicaImageViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaImageViewer';

  static const _i46.PageInfo<ReplicaImageViewerArgs> page =
      _i46.PageInfo<ReplicaImageViewerArgs>(name);
}

class ReplicaImageViewerArgs {
  const ReplicaImageViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i49.ReplicaApi replicaApi;

  final _i49.ReplicaSearchItem item;

  final _i49.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaImageViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i31.ReplicaLinkHandler]
class ReplicaLinkHandler extends _i46.PageRouteInfo<ReplicaLinkHandlerArgs> {
  ReplicaLinkHandler({
    _i48.Key? key,
    required _i49.ReplicaApi replicaApi,
    required _i49.ReplicaLink replicaLink,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaLinkHandler.name,
          args: ReplicaLinkHandlerArgs(
            key: key,
            replicaApi: replicaApi,
            replicaLink: replicaLink,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaLinkHandler';

  static const _i46.PageInfo<ReplicaLinkHandlerArgs> page =
      _i46.PageInfo<ReplicaLinkHandlerArgs>(name);
}

class ReplicaLinkHandlerArgs {
  const ReplicaLinkHandlerArgs({
    this.key,
    required this.replicaApi,
    required this.replicaLink,
  });

  final _i48.Key? key;

  final _i49.ReplicaApi replicaApi;

  final _i49.ReplicaLink replicaLink;

  @override
  String toString() {
    return 'ReplicaLinkHandlerArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink}';
  }
}

/// generated route for
/// [_i32.ReplicaMiscViewer]
class ReplicaMiscViewer extends _i46.PageRouteInfo<ReplicaMiscViewerArgs> {
  ReplicaMiscViewer({
    required _i49.ReplicaApi replicaApi,
    required _i49.ReplicaSearchItem item,
    required _i49.SearchCategory category,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaMiscViewer.name,
          args: ReplicaMiscViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaMiscViewer';

  static const _i46.PageInfo<ReplicaMiscViewerArgs> page =
      _i46.PageInfo<ReplicaMiscViewerArgs>(name);
}

class ReplicaMiscViewerArgs {
  const ReplicaMiscViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i49.ReplicaApi replicaApi;

  final _i49.ReplicaSearchItem item;

  final _i49.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaMiscViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i33.ReplicaUploadDescription]
class ReplicaUploadDescription
    extends _i46.PageRouteInfo<ReplicaUploadDescriptionArgs> {
  ReplicaUploadDescription({
    _i48.Key? key,
    required _i50.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaUploadDescription.name,
          args: ReplicaUploadDescriptionArgs(
            key: key,
            fileToUpload: fileToUpload,
            fileTitle: fileTitle,
            fileDescription: fileDescription,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaUploadDescription';

  static const _i46.PageInfo<ReplicaUploadDescriptionArgs> page =
      _i46.PageInfo<ReplicaUploadDescriptionArgs>(name);
}

class ReplicaUploadDescriptionArgs {
  const ReplicaUploadDescriptionArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i48.Key? key;

  final _i50.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadDescriptionArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i34.ReplicaUploadReview]
class ReplicaUploadReview extends _i46.PageRouteInfo<ReplicaUploadReviewArgs> {
  ReplicaUploadReview({
    _i48.Key? key,
    required _i50.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaUploadReview.name,
          args: ReplicaUploadReviewArgs(
            key: key,
            fileToUpload: fileToUpload,
            fileTitle: fileTitle,
            fileDescription: fileDescription,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaUploadReview';

  static const _i46.PageInfo<ReplicaUploadReviewArgs> page =
      _i46.PageInfo<ReplicaUploadReviewArgs>(name);
}

class ReplicaUploadReviewArgs {
  const ReplicaUploadReviewArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i48.Key? key;

  final _i50.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadReviewArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i35.ReplicaUploadTitle]
class ReplicaUploadTitle extends _i46.PageRouteInfo<ReplicaUploadTitleArgs> {
  ReplicaUploadTitle({
    _i48.Key? key,
    required _i50.File fileToUpload,
    String? fileTitle,
    String? fileDescription,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaUploadTitle.name,
          args: ReplicaUploadTitleArgs(
            key: key,
            fileToUpload: fileToUpload,
            fileTitle: fileTitle,
            fileDescription: fileDescription,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaUploadTitle';

  static const _i46.PageInfo<ReplicaUploadTitleArgs> page =
      _i46.PageInfo<ReplicaUploadTitleArgs>(name);
}

class ReplicaUploadTitleArgs {
  const ReplicaUploadTitleArgs({
    this.key,
    required this.fileToUpload,
    this.fileTitle,
    this.fileDescription,
  });

  final _i48.Key? key;

  final _i50.File fileToUpload;

  final String? fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadTitleArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i36.ReplicaVideoViewer]
class ReplicaVideoViewer extends _i46.PageRouteInfo<ReplicaVideoViewerArgs> {
  ReplicaVideoViewer({
    required _i49.ReplicaApi replicaApi,
    required _i49.ReplicaSearchItem item,
    required _i49.SearchCategory category,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReplicaVideoViewer.name,
          args: ReplicaVideoViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
          initialChildren: children,
        );

  static const String name = 'ReplicaVideoViewer';

  static const _i46.PageInfo<ReplicaVideoViewerArgs> page =
      _i46.PageInfo<ReplicaVideoViewerArgs>(name);
}

class ReplicaVideoViewerArgs {
  const ReplicaVideoViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i49.ReplicaApi replicaApi;

  final _i49.ReplicaSearchItem item;

  final _i49.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaVideoViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i37.ReportIssue]
class ReportIssue extends _i46.PageRouteInfo<ReportIssueArgs> {
  ReportIssue({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ReportIssue.name,
          args: ReportIssueArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ReportIssue';

  static const _i46.PageInfo<ReportIssueArgs> page =
      _i46.PageInfo<ReportIssueArgs>(name);
}

class ReportIssueArgs {
  const ReportIssueArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'ReportIssueArgs{key: $key}';
  }
}

/// generated route for
/// [_i38.ResellerCodeCheckout]
class ResellerCodeCheckout
    extends _i46.PageRouteInfo<ResellerCodeCheckoutArgs> {
  ResellerCodeCheckout({
    required bool isPro,
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ResellerCodeCheckout.name,
          args: ResellerCodeCheckoutArgs(
            isPro: isPro,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ResellerCodeCheckout';

  static const _i46.PageInfo<ResellerCodeCheckoutArgs> page =
      _i46.PageInfo<ResellerCodeCheckoutArgs>(name);
}

class ResellerCodeCheckoutArgs {
  const ResellerCodeCheckoutArgs({
    required this.isPro,
    this.key,
  });

  final bool isPro;

  final _i48.Key? key;

  @override
  String toString() {
    return 'ResellerCodeCheckoutArgs{isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i39.ResetPassword]
class ResetPassword extends _i46.PageRouteInfo<void> {
  const ResetPassword({List<_i46.PageRouteInfo>? children})
      : super(
          ResetPassword.name,
          initialChildren: children,
        );

  static const String name = 'ResetPassword';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i40.Settings]
class Settings extends _i46.PageRouteInfo<SettingsArgs> {
  Settings({
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          Settings.name,
          args: SettingsArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Settings';

  static const _i46.PageInfo<SettingsArgs> page =
      _i46.PageInfo<SettingsArgs>(name);
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i48.Key? key;

  @override
  String toString() {
    return 'SettingsArgs{key: $key}';
  }
}

/// generated route for
/// [_i41.SignIn]
class SignIn extends _i46.PageRouteInfo<SignInArgs> {
  SignIn({
    _i48.Key? key,
    bool resetPasswordFlow = false,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          SignIn.name,
          args: SignInArgs(
            key: key,
            resetPasswordFlow: resetPasswordFlow,
          ),
          initialChildren: children,
        );

  static const String name = 'SignIn';

  static const _i46.PageInfo<SignInArgs> page = _i46.PageInfo<SignInArgs>(name);
}

class SignInArgs {
  const SignInArgs({
    this.key,
    this.resetPasswordFlow = false,
  });

  final _i48.Key? key;

  final bool resetPasswordFlow;

  @override
  String toString() {
    return 'SignInArgs{key: $key, resetPasswordFlow: $resetPasswordFlow}';
  }
}

/// generated route for
/// [_i42.SplitTunneling]
class SplitTunneling extends _i46.PageRouteInfo<SplitTunnelingArgs> {
  SplitTunneling({
    _i51.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          SplitTunneling.name,
          args: SplitTunnelingArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SplitTunneling';

  static const _i46.PageInfo<SplitTunnelingArgs> page =
      _i46.PageInfo<SplitTunnelingArgs>(name);
}

class SplitTunnelingArgs {
  const SplitTunnelingArgs({this.key});

  final _i51.Key? key;

  @override
  String toString() {
    return 'SplitTunnelingArgs{key: $key}';
  }
}

/// generated route for
/// [_i43.StripeCheckout]
class StripeCheckout extends _i46.PageRouteInfo<StripeCheckoutArgs> {
  StripeCheckout({
    required _i48.Plan plan,
    required String email,
    String? refCode,
    required bool isPro,
    _i48.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          StripeCheckout.name,
          args: StripeCheckoutArgs(
            plan: plan,
            email: email,
            refCode: refCode,
            isPro: isPro,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'StripeCheckout';

  static const _i46.PageInfo<StripeCheckoutArgs> page =
      _i46.PageInfo<StripeCheckoutArgs>(name);
}

class StripeCheckoutArgs {
  const StripeCheckoutArgs({
    required this.plan,
    required this.email,
    this.refCode,
    required this.isPro,
    this.key,
  });

  final _i48.Plan plan;

  final String email;

  final String? refCode;

  final bool isPro;

  final _i48.Key? key;

  @override
  String toString() {
    return 'StripeCheckoutArgs{plan: $plan, email: $email, refCode: $refCode, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i44.Support]
class Support extends _i46.PageRouteInfo<void> {
  const Support({List<_i46.PageRouteInfo>? children})
      : super(
          Support.name,
          initialChildren: children,
        );

  static const String name = 'Support';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i45.Verification]
class Verification extends _i46.PageRouteInfo<VerificationArgs> {
  Verification({
    _i48.Key? key,
    required String email,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          Verification.name,
          args: VerificationArgs(
            key: key,
            email: email,
          ),
          initialChildren: children,
        );

  static const String name = 'Verification';

  static const _i46.PageInfo<VerificationArgs> page =
      _i46.PageInfo<VerificationArgs>(name);
}

class VerificationArgs {
  const VerificationArgs({
    this.key,
    required this.email,
  });

  final _i48.Key? key;

  final String email;

  @override
  String toString() {
    return 'VerificationArgs{key: $key, email: $email}';
  }
}

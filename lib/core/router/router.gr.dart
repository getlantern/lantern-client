// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i54;

import 'package:auto_route/auto_route.dart' as _i50;
import 'package:flutter/cupertino.dart' as _i55;
import 'package:lantern/account/account.dart' as _i2;
import 'package:lantern/account/account_management.dart' as _i1;
import 'package:lantern/account/auth/auth_landing.dart' as _i6;
import 'package:lantern/account/auth/change_email.dart' as _i11;
import 'package:lantern/account/auth/confirm_email.dart' as _i16;
import 'package:lantern/account/auth/create_account_email.dart' as _i19;
import 'package:lantern/account/auth/create_account_password.dart' as _i20;
import 'package:lantern/account/auth/reset_password.dart' as _i42;
import 'package:lantern/account/auth/sign_in.dart' as _i44;
import 'package:lantern/account/auth/sign_in_password.dart' as _i45;
import 'package:lantern/account/auth/verification.dart' as _i49;
import 'package:lantern/account/blocked_users.dart' as _i10;
import 'package:lantern/account/chat_number_account.dart' as _i12;
import 'package:lantern/account/device_linking/add_device.dart' as _i3;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i7;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i8;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i9;
import 'package:lantern/account/device_linking/link_device.dart' as _i28;
import 'package:lantern/account/invite_friends.dart' as _i25;
import 'package:lantern/account/language.dart' as _i26;
import 'package:lantern/account/lantern_desktop.dart' as _i27;
import 'package:lantern/account/recovery_key.dart' as _i31;
import 'package:lantern/account/report_issue.dart' as _i40;
import 'package:lantern/account/settings.dart' as _i43;
import 'package:lantern/account/split_tunneling.dart' as _i46;
import 'package:lantern/account/support.dart' as _i48;
import 'package:lantern/common/common.dart' as _i52;
import 'package:lantern/common/ui/app_webview.dart' as _i5;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i21;
import 'package:lantern/home.dart' as _i22;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i4;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i17;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i29;
import 'package:lantern/messaging/conversation/conversation.dart' as _i18;
import 'package:lantern/messaging/introductions/introduce.dart' as _i23;
import 'package:lantern/messaging/introductions/introductions.dart' as _i24;
import 'package:lantern/messaging/messaging.dart' as _i51;
import 'package:lantern/messaging/onboarding/chat_number_messaging.dart'
    as _i13;
import 'package:lantern/messaging/onboarding/chat_number_recovery.dart' as _i14;
import 'package:lantern/plans/checkout.dart' as _i15;
import 'package:lantern/plans/plans.dart' as _i30;
import 'package:lantern/plans/reseller_checkout.dart' as _i41;
import 'package:lantern/plans/stripe_checkout.dart' as _i47;
import 'package:lantern/replica/common.dart' as _i53;
import 'package:lantern/replica/link_handler.dart' as _i34;
import 'package:lantern/replica/ui/viewers/audio.dart' as _i32;
import 'package:lantern/replica/ui/viewers/image.dart' as _i33;
import 'package:lantern/replica/ui/viewers/misc.dart' as _i35;
import 'package:lantern/replica/ui/viewers/video.dart' as _i39;
import 'package:lantern/replica/upload/description.dart' as _i36;
import 'package:lantern/replica/upload/review.dart' as _i37;
import 'package:lantern/replica/upload/title.dart' as _i38;

abstract class $AppRouter extends _i50.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i50.PageFactory> pagesMap = {
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i1.AccountManagement(
          key: args.key,
          isPro: args.isPro,
        ),
      );
    },
    Account.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i2.AccountMenu(),
      );
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i3.AddDevice(key: args.key),
      );
    },
    AddViaChatNumber.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i4.AddViaChatNumber(),
      );
    },
    AppWebview.name: (routeData) {
      final args = routeData.argsAs<AppWebviewArgs>();
      return _i50.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i5.AppWebView(
          key: args.key,
          url: args.url,
        ),
      );
    },
    AuthLanding.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i6.AuthLanding(),
      );
    },
    AuthorizePro.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i7.AuthorizeDeviceForPro(),
      );
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i8.AuthorizeDeviceViaEmail(key: args.key),
      );
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i9.AuthorizeDeviceViaEmailPin(
          key: args.key,
          email: args.email,
        ),
      );
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i10.BlockedUsers(key: args.key),
      );
    },
    ChangeEmail.name: (routeData) {
      final args = routeData.argsAs<ChangeEmailArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i11.ChangeEmail(
          key: args.key,
          email: args.email,
        ),
      );
    },
    ChatNumberAccount.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i12.ChatNumberAccount(),
      );
    },
    ChatNumberMessaging.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i13.ChatNumberMessaging(),
      );
    },
    ChatNumberRecovery.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i14.ChatNumberRecovery(),
      );
    },
    Checkout.name: (routeData) {
      final args = routeData.argsAs<CheckoutArgs>();
      return _i50.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i15.Checkout(
          plan: args.plan,
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    ConfirmEmail.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i16.ConfirmEmail(),
      );
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i17.ContactInfo(contact: args.contact),
      );
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i18.Conversation(
          contactId: args.contactId,
          initialScrollIndex: args.initialScrollIndex,
          showContactEditingDialog: args.showContactEditingDialog,
        ),
      );
    },
    CreateAccountEmail.name: (routeData) {
      final args = routeData.argsAs<CreateAccountEmailArgs>(
          orElse: () => const CreateAccountEmailArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i19.CreateAccountEmail(
          key: args.key,
          plan: args.plan,
        ),
      );
    },
    CreateAccountPassword.name: (routeData) {
      final args = routeData.argsAs<CreateAccountPasswordArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i20.CreateAccountPassword(
          key: args.key,
          email: args.email,
        ),
      );
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i21.FullScreenDialog(
          widget: args.widget,
          key: args.key,
        ),
      );
    },
    Home.name: (routeData) {
      return _i50.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i22.HomePage(),
      );
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i23.Introduce(
          singleIntro: args.singleIntro,
          contactToIntro: args.contactToIntro,
        ),
      );
    },
    Introductions.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i24.Introductions(),
      );
    },
    InviteFriends.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i25.InviteFriends(),
      );
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i26.Language(key: args.key),
      );
    },
    LanternDesktop.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i27.LanternDesktop(),
      );
    },
    LinkDevice.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i28.LinkDevice(),
      );
    },
    NewChat.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i29.NewChat(),
      );
    },
    PlansPage.name: (routeData) {
      return _i50.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i30.PlansPage(),
      );
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i31.RecoveryKey(key: args.key),
      );
    },
    ReplicaAudioViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaAudioViewerArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i32.ReplicaAudioViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaImageViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaImageViewerArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i33.ReplicaImageViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaLinkHandler.name: (routeData) {
      final args = routeData.argsAs<ReplicaLinkHandlerArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i34.ReplicaLinkHandler(
          key: args.key,
          replicaApi: args.replicaApi,
          replicaLink: args.replicaLink,
        ),
      );
    },
    ReplicaMiscViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaMiscViewerArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i35.ReplicaMiscViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaUploadDescription.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadDescriptionArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i36.ReplicaUploadDescription(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadReview.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadReviewArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i37.ReplicaUploadReview(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadTitle.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadTitleArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i38.ReplicaUploadTitle(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaVideoViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaVideoViewerArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i39.ReplicaVideoViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReportIssue.name: (routeData) {
      final args = routeData.argsAs<ReportIssueArgs>(
          orElse: () => const ReportIssueArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i40.ReportIssue(key: args.key),
      );
    },
    ResellerCodeCheckout.name: (routeData) {
      final args = routeData.argsAs<ResellerCodeCheckoutArgs>();
      return _i50.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i41.ResellerCodeCheckout(
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    ResetPassword.name: (routeData) {
      final args = routeData.argsAs<ResetPasswordArgs>(
          orElse: () => const ResetPasswordArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i42.ResetPassword(
          key: args.key,
          email: args.email,
          code: args.code,
        ),
      );
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i50.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i43.Settings(key: args.key),
      );
    },
    SignIn.name: (routeData) {
      final args =
          routeData.argsAs<SignInArgs>(orElse: () => const SignInArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i44.SignIn(
          key: args.key,
          authFlow: args.authFlow,
        ),
      );
    },
    SignInPassword.name: (routeData) {
      final args = routeData.argsAs<SignInPasswordArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i45.SignInPassword(
          key: args.key,
          email: args.email,
        ),
      );
    },
    SplitTunneling.name: (routeData) {
      final args = routeData.argsAs<SplitTunnelingArgs>(
          orElse: () => const SplitTunnelingArgs());
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i46.SplitTunneling(key: args.key),
      );
    },
    StripeCheckout.name: (routeData) {
      final args = routeData.argsAs<StripeCheckoutArgs>();
      return _i50.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i47.StripeCheckout(
          plan: args.plan,
          email: args.email,
          refCode: args.refCode,
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    Support.name: (routeData) {
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i48.Support(),
      );
    },
    Verification.name: (routeData) {
      final args = routeData.argsAs<VerificationArgs>();
      return _i50.AutoRoutePage<void>(
        routeData: routeData,
        child: _i49.Verification(
          key: args.key,
          email: args.email,
          authFlow: args.authFlow,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.AccountManagement]
class AccountManagement extends _i50.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({
    _i51.Key? key,
    required bool isPro,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          AccountManagement.name,
          args: AccountManagementArgs(
            key: key,
            isPro: isPro,
          ),
          initialChildren: children,
        );

  static const String name = 'AccountManagement';

  static const _i50.PageInfo<AccountManagementArgs> page =
      _i50.PageInfo<AccountManagementArgs>(name);
}

class AccountManagementArgs {
  const AccountManagementArgs({
    this.key,
    required this.isPro,
  });

  final _i51.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for
/// [_i2.AccountMenu]
class Account extends _i50.PageRouteInfo<void> {
  const Account({List<_i50.PageRouteInfo>? children})
      : super(
          Account.name,
          initialChildren: children,
        );

  static const String name = 'Account';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i3.AddDevice]
class ApproveDevice extends _i50.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ApproveDevice.name,
          args: ApproveDeviceArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ApproveDevice';

  static const _i50.PageInfo<ApproveDeviceArgs> page =
      _i50.PageInfo<ApproveDeviceArgs>(name);
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i52.Key? key;

  @override
  String toString() {
    return 'ApproveDeviceArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.AddViaChatNumber]
class AddViaChatNumber extends _i50.PageRouteInfo<void> {
  const AddViaChatNumber({List<_i50.PageRouteInfo>? children})
      : super(
          AddViaChatNumber.name,
          initialChildren: children,
        );

  static const String name = 'AddViaChatNumber';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i5.AppWebView]
class AppWebview extends _i50.PageRouteInfo<AppWebviewArgs> {
  AppWebview({
    _i52.Key? key,
    required String url,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          AppWebview.name,
          args: AppWebviewArgs(
            key: key,
            url: url,
          ),
          initialChildren: children,
        );

  static const String name = 'AppWebview';

  static const _i50.PageInfo<AppWebviewArgs> page =
      _i50.PageInfo<AppWebviewArgs>(name);
}

class AppWebviewArgs {
  const AppWebviewArgs({
    this.key,
    required this.url,
  });

  final _i52.Key? key;

  final String url;

  @override
  String toString() {
    return 'AppWebviewArgs{key: $key, url: $url}';
  }
}

/// generated route for
/// [_i6.AuthLanding]
class AuthLanding extends _i50.PageRouteInfo<void> {
  const AuthLanding({List<_i50.PageRouteInfo>? children})
      : super(
          AuthLanding.name,
          initialChildren: children,
        );

  static const String name = 'AuthLanding';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i7.AuthorizeDeviceForPro]
class AuthorizePro extends _i50.PageRouteInfo<void> {
  const AuthorizePro({List<_i50.PageRouteInfo>? children})
      : super(
          AuthorizePro.name,
          initialChildren: children,
        );

  static const String name = 'AuthorizePro';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i8.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i50.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmail.name,
          args: AuthorizeDeviceEmailArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmail';

  static const _i50.PageInfo<AuthorizeDeviceEmailArgs> page =
      _i50.PageInfo<AuthorizeDeviceEmailArgs>(name);
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i52.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i50.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({
    _i52.Key? key,
    required String email,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmailPin.name,
          args: AuthorizeDeviceEmailPinArgs(
            key: key,
            email: email,
          ),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmailPin';

  static const _i50.PageInfo<AuthorizeDeviceEmailPinArgs> page =
      _i50.PageInfo<AuthorizeDeviceEmailPinArgs>(name);
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({
    this.key,
    required this.email,
  });

  final _i52.Key? key;

  final String email;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailPinArgs{key: $key, email: $email}';
  }
}

/// generated route for
/// [_i10.BlockedUsers]
class BlockedUsers extends _i50.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({
    _i51.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          BlockedUsers.name,
          args: BlockedUsersArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'BlockedUsers';

  static const _i50.PageInfo<BlockedUsersArgs> page =
      _i50.PageInfo<BlockedUsersArgs>(name);
}

class BlockedUsersArgs {
  const BlockedUsersArgs({this.key});

  final _i51.Key? key;

  @override
  String toString() {
    return 'BlockedUsersArgs{key: $key}';
  }
}

/// generated route for
/// [_i11.ChangeEmail]
class ChangeEmail extends _i50.PageRouteInfo<ChangeEmailArgs> {
  ChangeEmail({
    _i52.Key? key,
    required String email,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ChangeEmail.name,
          args: ChangeEmailArgs(
            key: key,
            email: email,
          ),
          initialChildren: children,
        );

  static const String name = 'ChangeEmail';

  static const _i50.PageInfo<ChangeEmailArgs> page =
      _i50.PageInfo<ChangeEmailArgs>(name);
}

class ChangeEmailArgs {
  const ChangeEmailArgs({
    this.key,
    required this.email,
  });

  final _i52.Key? key;

  final String email;

  @override
  String toString() {
    return 'ChangeEmailArgs{key: $key, email: $email}';
  }
}

/// generated route for
/// [_i12.ChatNumberAccount]
class ChatNumberAccount extends _i50.PageRouteInfo<void> {
  const ChatNumberAccount({List<_i50.PageRouteInfo>? children})
      : super(
          ChatNumberAccount.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberAccount';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i13.ChatNumberMessaging]
class ChatNumberMessaging extends _i50.PageRouteInfo<void> {
  const ChatNumberMessaging({List<_i50.PageRouteInfo>? children})
      : super(
          ChatNumberMessaging.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberMessaging';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i14.ChatNumberRecovery]
class ChatNumberRecovery extends _i50.PageRouteInfo<void> {
  const ChatNumberRecovery({List<_i50.PageRouteInfo>? children})
      : super(
          ChatNumberRecovery.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberRecovery';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i15.Checkout]
class Checkout extends _i50.PageRouteInfo<CheckoutArgs> {
  Checkout({
    required _i52.Plan plan,
    required bool isPro,
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<CheckoutArgs> page =
      _i50.PageInfo<CheckoutArgs>(name);
}

class CheckoutArgs {
  const CheckoutArgs({
    required this.plan,
    required this.isPro,
    this.key,
  });

  final _i52.Plan plan;

  final bool isPro;

  final _i52.Key? key;

  @override
  String toString() {
    return 'CheckoutArgs{plan: $plan, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i16.ConfirmEmail]
class ConfirmEmail extends _i50.PageRouteInfo<void> {
  const ConfirmEmail({List<_i50.PageRouteInfo>? children})
      : super(
          ConfirmEmail.name,
          initialChildren: children,
        );

  static const String name = 'ConfirmEmail';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i17.ContactInfo]
class ContactInfo extends _i50.PageRouteInfo<ContactInfoArgs> {
  ContactInfo({
    required _i51.Contact contact,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ContactInfo.name,
          args: ContactInfoArgs(contact: contact),
          initialChildren: children,
        );

  static const String name = 'ContactInfo';

  static const _i50.PageInfo<ContactInfoArgs> page =
      _i50.PageInfo<ContactInfoArgs>(name);
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.contact});

  final _i51.Contact contact;

  @override
  String toString() {
    return 'ContactInfoArgs{contact: $contact}';
  }
}

/// generated route for
/// [_i18.Conversation]
class Conversation extends _i50.PageRouteInfo<ConversationArgs> {
  Conversation({
    required _i51.ContactId contactId,
    int? initialScrollIndex,
    bool showContactEditingDialog = false,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ConversationArgs> page =
      _i50.PageInfo<ConversationArgs>(name);
}

class ConversationArgs {
  const ConversationArgs({
    required this.contactId,
    this.initialScrollIndex,
    this.showContactEditingDialog = false,
  });

  final _i51.ContactId contactId;

  final int? initialScrollIndex;

  final bool showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

/// generated route for
/// [_i19.CreateAccountEmail]
class CreateAccountEmail extends _i50.PageRouteInfo<CreateAccountEmailArgs> {
  CreateAccountEmail({
    _i52.Key? key,
    _i52.Plan? plan,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          CreateAccountEmail.name,
          args: CreateAccountEmailArgs(
            key: key,
            plan: plan,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateAccountEmail';

  static const _i50.PageInfo<CreateAccountEmailArgs> page =
      _i50.PageInfo<CreateAccountEmailArgs>(name);
}

class CreateAccountEmailArgs {
  const CreateAccountEmailArgs({
    this.key,
    this.plan,
  });

  final _i52.Key? key;

  final _i52.Plan? plan;

  @override
  String toString() {
    return 'CreateAccountEmailArgs{key: $key, plan: $plan}';
  }
}

/// generated route for
/// [_i20.CreateAccountPassword]
class CreateAccountPassword
    extends _i50.PageRouteInfo<CreateAccountPasswordArgs> {
  CreateAccountPassword({
    _i52.Key? key,
    required String email,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          CreateAccountPassword.name,
          args: CreateAccountPasswordArgs(
            key: key,
            email: email,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateAccountPassword';

  static const _i50.PageInfo<CreateAccountPasswordArgs> page =
      _i50.PageInfo<CreateAccountPasswordArgs>(name);
}

class CreateAccountPasswordArgs {
  const CreateAccountPasswordArgs({
    this.key,
    required this.email,
  });

  final _i52.Key? key;

  final String email;

  @override
  String toString() {
    return 'CreateAccountPasswordArgs{key: $key, email: $email}';
  }
}

/// generated route for
/// [_i21.FullScreenDialog]
class FullScreenDialogPage
    extends _i50.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({
    required _i52.Widget widget,
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          FullScreenDialogPage.name,
          args: FullScreenDialogPageArgs(
            widget: widget,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'FullScreenDialogPage';

  static const _i50.PageInfo<FullScreenDialogPageArgs> page =
      _i50.PageInfo<FullScreenDialogPageArgs>(name);
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({
    required this.widget,
    this.key,
  });

  final _i52.Widget widget;

  final _i52.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for
/// [_i22.HomePage]
class Home extends _i50.PageRouteInfo<void> {
  const Home({List<_i50.PageRouteInfo>? children})
      : super(
          Home.name,
          initialChildren: children,
        );

  static const String name = 'Home';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i23.Introduce]
class Introduce extends _i50.PageRouteInfo<IntroduceArgs> {
  Introduce({
    required bool singleIntro,
    _i51.Contact? contactToIntro,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          Introduce.name,
          args: IntroduceArgs(
            singleIntro: singleIntro,
            contactToIntro: contactToIntro,
          ),
          initialChildren: children,
        );

  static const String name = 'Introduce';

  static const _i50.PageInfo<IntroduceArgs> page =
      _i50.PageInfo<IntroduceArgs>(name);
}

class IntroduceArgs {
  const IntroduceArgs({
    required this.singleIntro,
    this.contactToIntro,
  });

  final bool singleIntro;

  final _i51.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for
/// [_i24.Introductions]
class Introductions extends _i50.PageRouteInfo<void> {
  const Introductions({List<_i50.PageRouteInfo>? children})
      : super(
          Introductions.name,
          initialChildren: children,
        );

  static const String name = 'Introductions';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i25.InviteFriends]
class InviteFriends extends _i50.PageRouteInfo<void> {
  const InviteFriends({List<_i50.PageRouteInfo>? children})
      : super(
          InviteFriends.name,
          initialChildren: children,
        );

  static const String name = 'InviteFriends';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i26.Language]
class Language extends _i50.PageRouteInfo<LanguageArgs> {
  Language({
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          Language.name,
          args: LanguageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Language';

  static const _i50.PageInfo<LanguageArgs> page =
      _i50.PageInfo<LanguageArgs>(name);
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i52.Key? key;

  @override
  String toString() {
    return 'LanguageArgs{key: $key}';
  }
}

/// generated route for
/// [_i27.LanternDesktop]
class LanternDesktop extends _i50.PageRouteInfo<void> {
  const LanternDesktop({List<_i50.PageRouteInfo>? children})
      : super(
          LanternDesktop.name,
          initialChildren: children,
        );

  static const String name = 'LanternDesktop';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i28.LinkDevice]
class LinkDevice extends _i50.PageRouteInfo<void> {
  const LinkDevice({List<_i50.PageRouteInfo>? children})
      : super(
          LinkDevice.name,
          initialChildren: children,
        );

  static const String name = 'LinkDevice';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i29.NewChat]
class NewChat extends _i50.PageRouteInfo<void> {
  const NewChat({List<_i50.PageRouteInfo>? children})
      : super(
          NewChat.name,
          initialChildren: children,
        );

  static const String name = 'NewChat';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i30.PlansPage]
class PlansPage extends _i50.PageRouteInfo<void> {
  const PlansPage({List<_i50.PageRouteInfo>? children})
      : super(
          PlansPage.name,
          initialChildren: children,
        );

  static const String name = 'PlansPage';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i31.RecoveryKey]
class RecoveryKey extends _i50.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({
    _i51.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          RecoveryKey.name,
          args: RecoveryKeyArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RecoveryKey';

  static const _i50.PageInfo<RecoveryKeyArgs> page =
      _i50.PageInfo<RecoveryKeyArgs>(name);
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i51.Key? key;

  @override
  String toString() {
    return 'RecoveryKeyArgs{key: $key}';
  }
}

/// generated route for
/// [_i32.ReplicaAudioViewer]
class ReplicaAudioViewer extends _i50.PageRouteInfo<ReplicaAudioViewerArgs> {
  ReplicaAudioViewer({
    required _i53.ReplicaApi replicaApi,
    required _i53.ReplicaSearchItem item,
    required _i53.SearchCategory category,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaAudioViewerArgs> page =
      _i50.PageInfo<ReplicaAudioViewerArgs>(name);
}

class ReplicaAudioViewerArgs {
  const ReplicaAudioViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i53.ReplicaApi replicaApi;

  final _i53.ReplicaSearchItem item;

  final _i53.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaAudioViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i33.ReplicaImageViewer]
class ReplicaImageViewer extends _i50.PageRouteInfo<ReplicaImageViewerArgs> {
  ReplicaImageViewer({
    required _i53.ReplicaApi replicaApi,
    required _i53.ReplicaSearchItem item,
    required _i53.SearchCategory category,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaImageViewerArgs> page =
      _i50.PageInfo<ReplicaImageViewerArgs>(name);
}

class ReplicaImageViewerArgs {
  const ReplicaImageViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i53.ReplicaApi replicaApi;

  final _i53.ReplicaSearchItem item;

  final _i53.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaImageViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i34.ReplicaLinkHandler]
class ReplicaLinkHandler extends _i50.PageRouteInfo<ReplicaLinkHandlerArgs> {
  ReplicaLinkHandler({
    _i52.Key? key,
    required _i53.ReplicaApi replicaApi,
    required _i53.ReplicaLink replicaLink,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaLinkHandlerArgs> page =
      _i50.PageInfo<ReplicaLinkHandlerArgs>(name);
}

class ReplicaLinkHandlerArgs {
  const ReplicaLinkHandlerArgs({
    this.key,
    required this.replicaApi,
    required this.replicaLink,
  });

  final _i52.Key? key;

  final _i53.ReplicaApi replicaApi;

  final _i53.ReplicaLink replicaLink;

  @override
  String toString() {
    return 'ReplicaLinkHandlerArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink}';
  }
}

/// generated route for
/// [_i35.ReplicaMiscViewer]
class ReplicaMiscViewer extends _i50.PageRouteInfo<ReplicaMiscViewerArgs> {
  ReplicaMiscViewer({
    required _i53.ReplicaApi replicaApi,
    required _i53.ReplicaSearchItem item,
    required _i53.SearchCategory category,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaMiscViewerArgs> page =
      _i50.PageInfo<ReplicaMiscViewerArgs>(name);
}

class ReplicaMiscViewerArgs {
  const ReplicaMiscViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i53.ReplicaApi replicaApi;

  final _i53.ReplicaSearchItem item;

  final _i53.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaMiscViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i36.ReplicaUploadDescription]
class ReplicaUploadDescription
    extends _i50.PageRouteInfo<ReplicaUploadDescriptionArgs> {
  ReplicaUploadDescription({
    _i52.Key? key,
    required _i54.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaUploadDescriptionArgs> page =
      _i50.PageInfo<ReplicaUploadDescriptionArgs>(name);
}

class ReplicaUploadDescriptionArgs {
  const ReplicaUploadDescriptionArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i52.Key? key;

  final _i54.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadDescriptionArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i37.ReplicaUploadReview]
class ReplicaUploadReview extends _i50.PageRouteInfo<ReplicaUploadReviewArgs> {
  ReplicaUploadReview({
    _i52.Key? key,
    required _i54.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaUploadReviewArgs> page =
      _i50.PageInfo<ReplicaUploadReviewArgs>(name);
}

class ReplicaUploadReviewArgs {
  const ReplicaUploadReviewArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i52.Key? key;

  final _i54.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadReviewArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i38.ReplicaUploadTitle]
class ReplicaUploadTitle extends _i50.PageRouteInfo<ReplicaUploadTitleArgs> {
  ReplicaUploadTitle({
    _i52.Key? key,
    required _i54.File fileToUpload,
    String? fileTitle,
    String? fileDescription,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaUploadTitleArgs> page =
      _i50.PageInfo<ReplicaUploadTitleArgs>(name);
}

class ReplicaUploadTitleArgs {
  const ReplicaUploadTitleArgs({
    this.key,
    required this.fileToUpload,
    this.fileTitle,
    this.fileDescription,
  });

  final _i52.Key? key;

  final _i54.File fileToUpload;

  final String? fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadTitleArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i39.ReplicaVideoViewer]
class ReplicaVideoViewer extends _i50.PageRouteInfo<ReplicaVideoViewerArgs> {
  ReplicaVideoViewer({
    required _i53.ReplicaApi replicaApi,
    required _i53.ReplicaSearchItem item,
    required _i53.SearchCategory category,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<ReplicaVideoViewerArgs> page =
      _i50.PageInfo<ReplicaVideoViewerArgs>(name);
}

class ReplicaVideoViewerArgs {
  const ReplicaVideoViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i53.ReplicaApi replicaApi;

  final _i53.ReplicaSearchItem item;

  final _i53.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaVideoViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i40.ReportIssue]
class ReportIssue extends _i50.PageRouteInfo<ReportIssueArgs> {
  ReportIssue({
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ReportIssue.name,
          args: ReportIssueArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ReportIssue';

  static const _i50.PageInfo<ReportIssueArgs> page =
      _i50.PageInfo<ReportIssueArgs>(name);
}

class ReportIssueArgs {
  const ReportIssueArgs({this.key});

  final _i52.Key? key;

  @override
  String toString() {
    return 'ReportIssueArgs{key: $key}';
  }
}

/// generated route for
/// [_i41.ResellerCodeCheckout]
class ResellerCodeCheckout
    extends _i50.PageRouteInfo<ResellerCodeCheckoutArgs> {
  ResellerCodeCheckout({
    required bool isPro,
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ResellerCodeCheckout.name,
          args: ResellerCodeCheckoutArgs(
            isPro: isPro,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ResellerCodeCheckout';

  static const _i50.PageInfo<ResellerCodeCheckoutArgs> page =
      _i50.PageInfo<ResellerCodeCheckoutArgs>(name);
}

class ResellerCodeCheckoutArgs {
  const ResellerCodeCheckoutArgs({
    required this.isPro,
    this.key,
  });

  final bool isPro;

  final _i52.Key? key;

  @override
  String toString() {
    return 'ResellerCodeCheckoutArgs{isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i42.ResetPassword]
class ResetPassword extends _i50.PageRouteInfo<ResetPasswordArgs> {
  ResetPassword({
    _i55.Key? key,
    String? email,
    String? code,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          ResetPassword.name,
          args: ResetPasswordArgs(
            key: key,
            email: email,
            code: code,
          ),
          initialChildren: children,
        );

  static const String name = 'ResetPassword';

  static const _i50.PageInfo<ResetPasswordArgs> page =
      _i50.PageInfo<ResetPasswordArgs>(name);
}

class ResetPasswordArgs {
  const ResetPasswordArgs({
    this.key,
    this.email,
    this.code,
  });

  final _i55.Key? key;

  final String? email;

  final String? code;

  @override
  String toString() {
    return 'ResetPasswordArgs{key: $key, email: $email, code: $code}';
  }
}

/// generated route for
/// [_i43.Settings]
class Settings extends _i50.PageRouteInfo<SettingsArgs> {
  Settings({
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          Settings.name,
          args: SettingsArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Settings';

  static const _i50.PageInfo<SettingsArgs> page =
      _i50.PageInfo<SettingsArgs>(name);
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i52.Key? key;

  @override
  String toString() {
    return 'SettingsArgs{key: $key}';
  }
}

/// generated route for
/// [_i44.SignIn]
class SignIn extends _i50.PageRouteInfo<SignInArgs> {
  SignIn({
    _i52.Key? key,
    _i52.AuthFlow authFlow = _i52.AuthFlow.signIn,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          SignIn.name,
          args: SignInArgs(
            key: key,
            authFlow: authFlow,
          ),
          initialChildren: children,
        );

  static const String name = 'SignIn';

  static const _i50.PageInfo<SignInArgs> page = _i50.PageInfo<SignInArgs>(name);
}

class SignInArgs {
  const SignInArgs({
    this.key,
    this.authFlow = _i52.AuthFlow.signIn,
  });

  final _i52.Key? key;

  final _i52.AuthFlow authFlow;

  @override
  String toString() {
    return 'SignInArgs{key: $key, authFlow: $authFlow}';
  }
}

/// generated route for
/// [_i45.SignInPassword]
class SignInPassword extends _i50.PageRouteInfo<SignInPasswordArgs> {
  SignInPassword({
    _i52.Key? key,
    required String email,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          SignInPassword.name,
          args: SignInPasswordArgs(
            key: key,
            email: email,
          ),
          initialChildren: children,
        );

  static const String name = 'SignInPassword';

  static const _i50.PageInfo<SignInPasswordArgs> page =
      _i50.PageInfo<SignInPasswordArgs>(name);
}

class SignInPasswordArgs {
  const SignInPasswordArgs({
    this.key,
    required this.email,
  });

  final _i52.Key? key;

  final String email;

  @override
  String toString() {
    return 'SignInPasswordArgs{key: $key, email: $email}';
  }
}

/// generated route for
/// [_i46.SplitTunneling]
class SplitTunneling extends _i50.PageRouteInfo<SplitTunnelingArgs> {
  SplitTunneling({
    _i55.Key? key,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          SplitTunneling.name,
          args: SplitTunnelingArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SplitTunneling';

  static const _i50.PageInfo<SplitTunnelingArgs> page =
      _i50.PageInfo<SplitTunnelingArgs>(name);
}

class SplitTunnelingArgs {
  const SplitTunnelingArgs({this.key});

  final _i55.Key? key;

  @override
  String toString() {
    return 'SplitTunnelingArgs{key: $key}';
  }
}

/// generated route for
/// [_i47.StripeCheckout]
class StripeCheckout extends _i50.PageRouteInfo<StripeCheckoutArgs> {
  StripeCheckout({
    required _i52.Plan plan,
    required String email,
    String? refCode,
    required bool isPro,
    _i52.Key? key,
    List<_i50.PageRouteInfo>? children,
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

  static const _i50.PageInfo<StripeCheckoutArgs> page =
      _i50.PageInfo<StripeCheckoutArgs>(name);
}

class StripeCheckoutArgs {
  const StripeCheckoutArgs({
    required this.plan,
    required this.email,
    this.refCode,
    required this.isPro,
    this.key,
  });

  final _i52.Plan plan;

  final String email;

  final String? refCode;

  final bool isPro;

  final _i52.Key? key;

  @override
  String toString() {
    return 'StripeCheckoutArgs{plan: $plan, email: $email, refCode: $refCode, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i48.Support]
class Support extends _i50.PageRouteInfo<void> {
  const Support({List<_i50.PageRouteInfo>? children})
      : super(
          Support.name,
          initialChildren: children,
        );

  static const String name = 'Support';

  static const _i50.PageInfo<void> page = _i50.PageInfo<void>(name);
}

/// generated route for
/// [_i49.Verification]
class Verification extends _i50.PageRouteInfo<VerificationArgs> {
  Verification({
    _i52.Key? key,
    required String email,
    _i52.AuthFlow authFlow = _i52.AuthFlow.reset,
    List<_i50.PageRouteInfo>? children,
  }) : super(
          Verification.name,
          args: VerificationArgs(
            key: key,
            email: email,
            authFlow: authFlow,
          ),
          initialChildren: children,
        );

  static const String name = 'Verification';

  static const _i50.PageInfo<VerificationArgs> page =
      _i50.PageInfo<VerificationArgs>(name);
}

class VerificationArgs {
  const VerificationArgs({
    this.key,
    required this.email,
    this.authFlow = _i52.AuthFlow.reset,
  });

  final _i52.Key? key;

  final String email;

  final _i52.AuthFlow authFlow;

  @override
  String toString() {
    return 'VerificationArgs{key: $key, email: $email, authFlow: $authFlow}';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i43;

import 'package:auto_route/auto_route.dart' as _i40;
import 'package:flutter/cupertino.dart' as _i45;
import 'package:lantern/account/account.dart' as _i23;
import 'package:lantern/account/account_management.dart' as _i17;
import 'package:lantern/account/blocked_users.dart' as _i29;
import 'package:lantern/account/chat_number_account.dart' as _i27;
import 'package:lantern/account/device_linking/approve_device.dart' as _i19;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i22;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i21;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i18;
import 'package:lantern/account/device_linking/link_device.dart' as _i20;
import 'package:lantern/account/invite_friends.dart' as _i26;
import 'package:lantern/account/language.dart' as _i30;
import 'package:lantern/account/lantern_desktop.dart' as _i25;
import 'package:lantern/account/recovery_key.dart' as _i16;
import 'package:lantern/account/report_issue.dart' as _i15;
import 'package:lantern/account/settings.dart' as _i31;
import 'package:lantern/account/split_tunneling.dart' as _i28;
import 'package:lantern/account/support.dart' as _i24;
import 'package:lantern/common/common.dart' as _i41;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i6;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i32;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i33;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i34;
import 'package:lantern/messaging/conversation/conversation.dart' as _i39;
import 'package:lantern/messaging/introductions/introduce.dart' as _i36;
import 'package:lantern/messaging/introductions/introductions.dart' as _i35;
import 'package:lantern/messaging/messaging.dart' as _i44;
import 'package:lantern/messaging/onboarding/chat_number_messaging.dart'
    as _i38;
import 'package:lantern/messaging/onboarding/chat_number_recovery.dart' as _i37;
import 'package:lantern/plans/checkout.dart' as _i5;
import 'package:lantern/plans/plans.dart' as _i3;
import 'package:lantern/plans/reseller_checkout.dart' as _i2;
import 'package:lantern/plans/stripe_checkout.dart' as _i4;
import 'package:lantern/replica/common.dart' as _i42;
import 'package:lantern/replica/link_handler.dart' as _i11;
import 'package:lantern/replica/ui/viewers/audio.dart' as _i7;
import 'package:lantern/replica/ui/viewers/image.dart' as _i8;
import 'package:lantern/replica/ui/viewers/misc.dart' as _i10;
import 'package:lantern/replica/ui/viewers/video.dart' as _i9;
import 'package:lantern/replica/upload/description.dart' as _i13;
import 'package:lantern/replica/upload/review.dart' as _i12;
import 'package:lantern/replica/upload/title.dart' as _i14;

abstract class $AppRouter extends _i40.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i40.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i40.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.HomePage(key: args.key),
      );
    },
    ResellerCodeCheckout.name: (routeData) {
      final args = routeData.argsAs<ResellerCodeCheckoutArgs>();
      return _i40.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.ResellerCodeCheckout(
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    PlansPage.name: (routeData) {
      return _i40.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.PlansPage(),
      );
    },
    StripeCheckout.name: (routeData) {
      final args = routeData.argsAs<StripeCheckoutArgs>();
      return _i40.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.StripeCheckout(
          plan: args.plan,
          email: args.email,
          refCode: args.refCode,
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    Checkout.name: (routeData) {
      final args = routeData.argsAs<CheckoutArgs>();
      return _i40.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i5.Checkout(
          plan: args.plan,
          isPro: args.isPro,
          key: args.key,
        ),
      );
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i6.FullScreenDialog(
          widget: args.widget,
          key: args.key,
        ),
      );
    },
    ReplicaAudioViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaAudioViewerArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i7.ReplicaAudioViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaImageViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaImageViewerArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i8.ReplicaImageViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaVideoViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaVideoViewerArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i9.ReplicaVideoViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaMiscViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaMiscViewerArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i10.ReplicaMiscViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaLinkHandler.name: (routeData) {
      final args = routeData.argsAs<ReplicaLinkHandlerArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i11.ReplicaLinkHandler(
          key: args.key,
          replicaApi: args.replicaApi,
          replicaLink: args.replicaLink,
        ),
      );
    },
    ReplicaUploadReview.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadReviewArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i12.ReplicaUploadReview(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadDescription.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadDescriptionArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i13.ReplicaUploadDescription(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadTitle.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadTitleArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i14.ReplicaUploadTitle(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReportIssue.name: (routeData) {
      final args = routeData.argsAs<ReportIssueArgs>(
          orElse: () => const ReportIssueArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i15.ReportIssue(key: args.key),
      );
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i16.RecoveryKey(key: args.key),
      );
    },
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i17.AccountManagement(
          key: args.key,
          isPro: args.isPro,
        ),
      );
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i18.AuthorizeDeviceViaEmailPin(key: args.key),
      );
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i19.ApproveDevice(key: args.key),
      );
    },
    LinkDevice.name: (routeData) {
      final args = routeData.argsAs<LinkDeviceArgs>(
          orElse: () => const LinkDeviceArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i20.LinkDevice(key: args.key),
      );
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i21.AuthorizeDeviceViaEmail(key: args.key),
      );
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i22.AuthorizeDeviceForPro(key: args.key),
      );
    },
    Account.name: (routeData) {
      final args =
          routeData.argsAs<AccountArgs>(orElse: () => const AccountArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i23.AccountMenu(key: args.key),
      );
    },
    Support.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i24.Support(),
      );
    },
    LanternDesktop.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i25.LanternDesktop(),
      );
    },
    InviteFriends.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i26.InviteFriends(),
      );
    },
    ChatNumberAccount.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i27.ChatNumberAccount(),
      );
    },
    SplitTunneling.name: (routeData) {
      final args = routeData.argsAs<SplitTunnelingArgs>(
          orElse: () => const SplitTunnelingArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i28.SplitTunneling(key: args.key),
      );
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i29.BlockedUsers(key: args.key),
      );
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i30.Language(key: args.key),
      );
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i40.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i31.Settings(key: args.key),
      );
    },
    AddViaChatNumber.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i32.AddViaChatNumber(),
      );
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i33.ContactInfo(contact: args.contact),
      );
    },
    NewChat.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i34.NewChat(),
      );
    },
    Introductions.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i35.Introductions(),
      );
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i36.Introduce(
          singleIntro: args.singleIntro,
          contactToIntro: args.contactToIntro,
        ),
      );
    },
    ChatNumberRecovery.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i37.ChatNumberRecovery(),
      );
    },
    ChatNumberMessaging.name: (routeData) {
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i38.ChatNumberMessaging(),
      );
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i40.AutoRoutePage<void>(
        routeData: routeData,
        child: _i39.Conversation(
          contactId: args.contactId,
          initialScrollIndex: args.initialScrollIndex,
          showContactEditingDialog: args.showContactEditingDialog,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.HomePage]
class Home extends _i40.PageRouteInfo<HomeArgs> {
  Home({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          Home.name,
          args: HomeArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Home';

  static const _i40.PageInfo<HomeArgs> page = _i40.PageInfo<HomeArgs>(name);
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'HomeArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.ResellerCodeCheckout]
class ResellerCodeCheckout
    extends _i40.PageRouteInfo<ResellerCodeCheckoutArgs> {
  ResellerCodeCheckout({
    required bool isPro,
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          ResellerCodeCheckout.name,
          args: ResellerCodeCheckoutArgs(
            isPro: isPro,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ResellerCodeCheckout';

  static const _i40.PageInfo<ResellerCodeCheckoutArgs> page =
      _i40.PageInfo<ResellerCodeCheckoutArgs>(name);
}

class ResellerCodeCheckoutArgs {
  const ResellerCodeCheckoutArgs({
    required this.isPro,
    this.key,
  });

  final bool isPro;

  final _i41.Key? key;

  @override
  String toString() {
    return 'ResellerCodeCheckoutArgs{isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i3.PlansPage]
class PlansPage extends _i40.PageRouteInfo<void> {
  const PlansPage({List<_i40.PageRouteInfo>? children})
      : super(
          PlansPage.name,
          initialChildren: children,
        );

  static const String name = 'PlansPage';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i4.StripeCheckout]
class StripeCheckout extends _i40.PageRouteInfo<StripeCheckoutArgs> {
  StripeCheckout({
    required _i41.Plan plan,
    required String email,
    String? refCode,
    required bool isPro,
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<StripeCheckoutArgs> page =
      _i40.PageInfo<StripeCheckoutArgs>(name);
}

class StripeCheckoutArgs {
  const StripeCheckoutArgs({
    required this.plan,
    required this.email,
    this.refCode,
    required this.isPro,
    this.key,
  });

  final _i41.Plan plan;

  final String email;

  final String? refCode;

  final bool isPro;

  final _i41.Key? key;

  @override
  String toString() {
    return 'StripeCheckoutArgs{plan: $plan, email: $email, refCode: $refCode, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i5.Checkout]
class Checkout extends _i40.PageRouteInfo<CheckoutArgs> {
  Checkout({
    required _i41.Plan plan,
    required bool isPro,
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<CheckoutArgs> page =
      _i40.PageInfo<CheckoutArgs>(name);
}

class CheckoutArgs {
  const CheckoutArgs({
    required this.plan,
    required this.isPro,
    this.key,
  });

  final _i41.Plan plan;

  final bool isPro;

  final _i41.Key? key;

  @override
  String toString() {
    return 'CheckoutArgs{plan: $plan, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i6.FullScreenDialog]
class FullScreenDialogPage
    extends _i40.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({
    required _i41.Widget widget,
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          FullScreenDialogPage.name,
          args: FullScreenDialogPageArgs(
            widget: widget,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'FullScreenDialogPage';

  static const _i40.PageInfo<FullScreenDialogPageArgs> page =
      _i40.PageInfo<FullScreenDialogPageArgs>(name);
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({
    required this.widget,
    this.key,
  });

  final _i41.Widget widget;

  final _i41.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for
/// [_i7.ReplicaAudioViewer]
class ReplicaAudioViewer extends _i40.PageRouteInfo<ReplicaAudioViewerArgs> {
  ReplicaAudioViewer({
    required _i42.ReplicaApi replicaApi,
    required _i42.ReplicaSearchItem item,
    required _i42.SearchCategory category,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaAudioViewerArgs> page =
      _i40.PageInfo<ReplicaAudioViewerArgs>(name);
}

class ReplicaAudioViewerArgs {
  const ReplicaAudioViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i42.ReplicaApi replicaApi;

  final _i42.ReplicaSearchItem item;

  final _i42.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaAudioViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i8.ReplicaImageViewer]
class ReplicaImageViewer extends _i40.PageRouteInfo<ReplicaImageViewerArgs> {
  ReplicaImageViewer({
    required _i42.ReplicaApi replicaApi,
    required _i42.ReplicaSearchItem item,
    required _i42.SearchCategory category,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaImageViewerArgs> page =
      _i40.PageInfo<ReplicaImageViewerArgs>(name);
}

class ReplicaImageViewerArgs {
  const ReplicaImageViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i42.ReplicaApi replicaApi;

  final _i42.ReplicaSearchItem item;

  final _i42.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaImageViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i9.ReplicaVideoViewer]
class ReplicaVideoViewer extends _i40.PageRouteInfo<ReplicaVideoViewerArgs> {
  ReplicaVideoViewer({
    required _i42.ReplicaApi replicaApi,
    required _i42.ReplicaSearchItem item,
    required _i42.SearchCategory category,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaVideoViewerArgs> page =
      _i40.PageInfo<ReplicaVideoViewerArgs>(name);
}

class ReplicaVideoViewerArgs {
  const ReplicaVideoViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i42.ReplicaApi replicaApi;

  final _i42.ReplicaSearchItem item;

  final _i42.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaVideoViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i10.ReplicaMiscViewer]
class ReplicaMiscViewer extends _i40.PageRouteInfo<ReplicaMiscViewerArgs> {
  ReplicaMiscViewer({
    required _i42.ReplicaApi replicaApi,
    required _i42.ReplicaSearchItem item,
    required _i42.SearchCategory category,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaMiscViewerArgs> page =
      _i40.PageInfo<ReplicaMiscViewerArgs>(name);
}

class ReplicaMiscViewerArgs {
  const ReplicaMiscViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i42.ReplicaApi replicaApi;

  final _i42.ReplicaSearchItem item;

  final _i42.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaMiscViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i11.ReplicaLinkHandler]
class ReplicaLinkHandler extends _i40.PageRouteInfo<ReplicaLinkHandlerArgs> {
  ReplicaLinkHandler({
    _i41.Key? key,
    required _i42.ReplicaApi replicaApi,
    required _i42.ReplicaLink replicaLink,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaLinkHandlerArgs> page =
      _i40.PageInfo<ReplicaLinkHandlerArgs>(name);
}

class ReplicaLinkHandlerArgs {
  const ReplicaLinkHandlerArgs({
    this.key,
    required this.replicaApi,
    required this.replicaLink,
  });

  final _i41.Key? key;

  final _i42.ReplicaApi replicaApi;

  final _i42.ReplicaLink replicaLink;

  @override
  String toString() {
    return 'ReplicaLinkHandlerArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink}';
  }
}

/// generated route for
/// [_i12.ReplicaUploadReview]
class ReplicaUploadReview extends _i40.PageRouteInfo<ReplicaUploadReviewArgs> {
  ReplicaUploadReview({
    _i41.Key? key,
    required _i43.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaUploadReviewArgs> page =
      _i40.PageInfo<ReplicaUploadReviewArgs>(name);
}

class ReplicaUploadReviewArgs {
  const ReplicaUploadReviewArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i41.Key? key;

  final _i43.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadReviewArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i13.ReplicaUploadDescription]
class ReplicaUploadDescription
    extends _i40.PageRouteInfo<ReplicaUploadDescriptionArgs> {
  ReplicaUploadDescription({
    _i41.Key? key,
    required _i43.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaUploadDescriptionArgs> page =
      _i40.PageInfo<ReplicaUploadDescriptionArgs>(name);
}

class ReplicaUploadDescriptionArgs {
  const ReplicaUploadDescriptionArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i41.Key? key;

  final _i43.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadDescriptionArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i14.ReplicaUploadTitle]
class ReplicaUploadTitle extends _i40.PageRouteInfo<ReplicaUploadTitleArgs> {
  ReplicaUploadTitle({
    _i41.Key? key,
    required _i43.File fileToUpload,
    String? fileTitle,
    String? fileDescription,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ReplicaUploadTitleArgs> page =
      _i40.PageInfo<ReplicaUploadTitleArgs>(name);
}

class ReplicaUploadTitleArgs {
  const ReplicaUploadTitleArgs({
    this.key,
    required this.fileToUpload,
    this.fileTitle,
    this.fileDescription,
  });

  final _i41.Key? key;

  final _i43.File fileToUpload;

  final String? fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadTitleArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i15.ReportIssue]
class ReportIssue extends _i40.PageRouteInfo<ReportIssueArgs> {
  ReportIssue({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          ReportIssue.name,
          args: ReportIssueArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ReportIssue';

  static const _i40.PageInfo<ReportIssueArgs> page =
      _i40.PageInfo<ReportIssueArgs>(name);
}

class ReportIssueArgs {
  const ReportIssueArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'ReportIssueArgs{key: $key}';
  }
}

/// generated route for
/// [_i16.RecoveryKey]
class RecoveryKey extends _i40.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({
    _i44.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          RecoveryKey.name,
          args: RecoveryKeyArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RecoveryKey';

  static const _i40.PageInfo<RecoveryKeyArgs> page =
      _i40.PageInfo<RecoveryKeyArgs>(name);
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i44.Key? key;

  @override
  String toString() {
    return 'RecoveryKeyArgs{key: $key}';
  }
}

/// generated route for
/// [_i17.AccountManagement]
class AccountManagement extends _i40.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({
    _i44.Key? key,
    required bool isPro,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          AccountManagement.name,
          args: AccountManagementArgs(
            key: key,
            isPro: isPro,
          ),
          initialChildren: children,
        );

  static const String name = 'AccountManagement';

  static const _i40.PageInfo<AccountManagementArgs> page =
      _i40.PageInfo<AccountManagementArgs>(name);
}

class AccountManagementArgs {
  const AccountManagementArgs({
    this.key,
    required this.isPro,
  });

  final _i44.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for
/// [_i18.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i40.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmailPin.name,
          args: AuthorizeDeviceEmailPinArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmailPin';

  static const _i40.PageInfo<AuthorizeDeviceEmailPinArgs> page =
      _i40.PageInfo<AuthorizeDeviceEmailPinArgs>(name);
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailPinArgs{key: $key}';
  }
}

/// generated route for
/// [_i19.ApproveDevice]
class ApproveDevice extends _i40.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          ApproveDevice.name,
          args: ApproveDeviceArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ApproveDevice';

  static const _i40.PageInfo<ApproveDeviceArgs> page =
      _i40.PageInfo<ApproveDeviceArgs>(name);
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'ApproveDeviceArgs{key: $key}';
  }
}

/// generated route for
/// [_i20.LinkDevice]
class LinkDevice extends _i40.PageRouteInfo<LinkDeviceArgs> {
  LinkDevice({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          LinkDevice.name,
          args: LinkDeviceArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'LinkDevice';

  static const _i40.PageInfo<LinkDeviceArgs> page =
      _i40.PageInfo<LinkDeviceArgs>(name);
}

class LinkDeviceArgs {
  const LinkDeviceArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'LinkDeviceArgs{key: $key}';
  }
}

/// generated route for
/// [_i21.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i40.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmail.name,
          args: AuthorizeDeviceEmailArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmail';

  static const _i40.PageInfo<AuthorizeDeviceEmailArgs> page =
      _i40.PageInfo<AuthorizeDeviceEmailArgs>(name);
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailArgs{key: $key}';
  }
}

/// generated route for
/// [_i22.AuthorizeDeviceForPro]
class AuthorizePro extends _i40.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          AuthorizePro.name,
          args: AuthorizeProArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizePro';

  static const _i40.PageInfo<AuthorizeProArgs> page =
      _i40.PageInfo<AuthorizeProArgs>(name);
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'AuthorizeProArgs{key: $key}';
  }
}

/// generated route for
/// [_i23.AccountMenu]
class Account extends _i40.PageRouteInfo<AccountArgs> {
  Account({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          Account.name,
          args: AccountArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Account';

  static const _i40.PageInfo<AccountArgs> page =
      _i40.PageInfo<AccountArgs>(name);
}

class AccountArgs {
  const AccountArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'AccountArgs{key: $key}';
  }
}

/// generated route for
/// [_i24.Support]
class Support extends _i40.PageRouteInfo<void> {
  const Support({List<_i40.PageRouteInfo>? children})
      : super(
          Support.name,
          initialChildren: children,
        );

  static const String name = 'Support';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i25.LanternDesktop]
class LanternDesktop extends _i40.PageRouteInfo<void> {
  const LanternDesktop({List<_i40.PageRouteInfo>? children})
      : super(
          LanternDesktop.name,
          initialChildren: children,
        );

  static const String name = 'LanternDesktop';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i26.InviteFriends]
class InviteFriends extends _i40.PageRouteInfo<void> {
  const InviteFriends({List<_i40.PageRouteInfo>? children})
      : super(
          InviteFriends.name,
          initialChildren: children,
        );

  static const String name = 'InviteFriends';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i27.ChatNumberAccount]
class ChatNumberAccount extends _i40.PageRouteInfo<void> {
  const ChatNumberAccount({List<_i40.PageRouteInfo>? children})
      : super(
          ChatNumberAccount.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberAccount';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i28.SplitTunneling]
class SplitTunneling extends _i40.PageRouteInfo<SplitTunnelingArgs> {
  SplitTunneling({
    _i45.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          SplitTunneling.name,
          args: SplitTunnelingArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SplitTunneling';

  static const _i40.PageInfo<SplitTunnelingArgs> page =
      _i40.PageInfo<SplitTunnelingArgs>(name);
}

class SplitTunnelingArgs {
  const SplitTunnelingArgs({this.key});

  final _i45.Key? key;

  @override
  String toString() {
    return 'SplitTunnelingArgs{key: $key}';
  }
}

/// generated route for
/// [_i29.BlockedUsers]
class BlockedUsers extends _i40.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({
    _i44.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          BlockedUsers.name,
          args: BlockedUsersArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'BlockedUsers';

  static const _i40.PageInfo<BlockedUsersArgs> page =
      _i40.PageInfo<BlockedUsersArgs>(name);
}

class BlockedUsersArgs {
  const BlockedUsersArgs({this.key});

  final _i44.Key? key;

  @override
  String toString() {
    return 'BlockedUsersArgs{key: $key}';
  }
}

/// generated route for
/// [_i30.Language]
class Language extends _i40.PageRouteInfo<LanguageArgs> {
  Language({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          Language.name,
          args: LanguageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Language';

  static const _i40.PageInfo<LanguageArgs> page =
      _i40.PageInfo<LanguageArgs>(name);
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'LanguageArgs{key: $key}';
  }
}

/// generated route for
/// [_i31.Settings]
class Settings extends _i40.PageRouteInfo<SettingsArgs> {
  Settings({
    _i41.Key? key,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          Settings.name,
          args: SettingsArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Settings';

  static const _i40.PageInfo<SettingsArgs> page =
      _i40.PageInfo<SettingsArgs>(name);
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i41.Key? key;

  @override
  String toString() {
    return 'SettingsArgs{key: $key}';
  }
}

/// generated route for
/// [_i32.AddViaChatNumber]
class AddViaChatNumber extends _i40.PageRouteInfo<void> {
  const AddViaChatNumber({List<_i40.PageRouteInfo>? children})
      : super(
          AddViaChatNumber.name,
          initialChildren: children,
        );

  static const String name = 'AddViaChatNumber';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i33.ContactInfo]
class ContactInfo extends _i40.PageRouteInfo<ContactInfoArgs> {
  ContactInfo({
    required _i44.Contact contact,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          ContactInfo.name,
          args: ContactInfoArgs(contact: contact),
          initialChildren: children,
        );

  static const String name = 'ContactInfo';

  static const _i40.PageInfo<ContactInfoArgs> page =
      _i40.PageInfo<ContactInfoArgs>(name);
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.contact});

  final _i44.Contact contact;

  @override
  String toString() {
    return 'ContactInfoArgs{contact: $contact}';
  }
}

/// generated route for
/// [_i34.NewChat]
class NewChat extends _i40.PageRouteInfo<void> {
  const NewChat({List<_i40.PageRouteInfo>? children})
      : super(
          NewChat.name,
          initialChildren: children,
        );

  static const String name = 'NewChat';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i35.Introductions]
class Introductions extends _i40.PageRouteInfo<void> {
  const Introductions({List<_i40.PageRouteInfo>? children})
      : super(
          Introductions.name,
          initialChildren: children,
        );

  static const String name = 'Introductions';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i36.Introduce]
class Introduce extends _i40.PageRouteInfo<IntroduceArgs> {
  Introduce({
    required bool singleIntro,
    _i44.Contact? contactToIntro,
    List<_i40.PageRouteInfo>? children,
  }) : super(
          Introduce.name,
          args: IntroduceArgs(
            singleIntro: singleIntro,
            contactToIntro: contactToIntro,
          ),
          initialChildren: children,
        );

  static const String name = 'Introduce';

  static const _i40.PageInfo<IntroduceArgs> page =
      _i40.PageInfo<IntroduceArgs>(name);
}

class IntroduceArgs {
  const IntroduceArgs({
    required this.singleIntro,
    this.contactToIntro,
  });

  final bool singleIntro;

  final _i44.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for
/// [_i37.ChatNumberRecovery]
class ChatNumberRecovery extends _i40.PageRouteInfo<void> {
  const ChatNumberRecovery({List<_i40.PageRouteInfo>? children})
      : super(
          ChatNumberRecovery.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberRecovery';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i38.ChatNumberMessaging]
class ChatNumberMessaging extends _i40.PageRouteInfo<void> {
  const ChatNumberMessaging({List<_i40.PageRouteInfo>? children})
      : super(
          ChatNumberMessaging.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberMessaging';

  static const _i40.PageInfo<void> page = _i40.PageInfo<void>(name);
}

/// generated route for
/// [_i39.Conversation]
class Conversation extends _i40.PageRouteInfo<ConversationArgs> {
  Conversation({
    required _i44.ContactId contactId,
    int? initialScrollIndex,
    bool showContactEditingDialog = false,
    List<_i40.PageRouteInfo>? children,
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

  static const _i40.PageInfo<ConversationArgs> page =
      _i40.PageInfo<ConversationArgs>(name);
}

class ConversationArgs {
  const ConversationArgs({
    required this.contactId,
    this.initialScrollIndex,
    this.showContactEditingDialog = false,
  });

  final _i44.ContactId contactId;

  final int? initialScrollIndex;

  final bool showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

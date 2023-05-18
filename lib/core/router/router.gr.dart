// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i36;

import 'package:auto_route/auto_route.dart' as _i33;
import 'package:flutter/material.dart' as _i34;
import 'package:lantern/account/account_management.dart' as _i3;
import 'package:lantern/account/blocked_users.dart' as _i20;
import 'package:lantern/account/chat_number_account.dart' as _i19;
import 'package:lantern/account/device_linking/approve_device.dart' as _i9;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i6;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i7;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i8;
import 'package:lantern/account/language.dart' as _i5;
import 'package:lantern/account/recovery_key.dart' as _i10;
import 'package:lantern/account/settings.dart' as _i4;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i2;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i16;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i14;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i15;
import 'package:lantern/messaging/conversation/conversation.dart' as _i13;
import 'package:lantern/messaging/introductions/introduce.dart' as _i17;
import 'package:lantern/messaging/introductions/introductions.dart' as _i18;
import 'package:lantern/messaging/messaging.dart' as _i35;
import 'package:lantern/messaging/onboarding/chat_number_messaging.dart'
    as _i12;
import 'package:lantern/messaging/onboarding/chat_number_recovery.dart' as _i11;
import 'package:lantern/plans/checkout.dart' as _i21;
import 'package:lantern/plans/plans.dart' as _i24;
import 'package:lantern/plans/reseller_checkout.dart' as _i22;
import 'package:lantern/plans/stripe_checkout.dart' as _i23;
import 'package:lantern/replica/common.dart' as _i37;
import 'package:lantern/replica/link_handler.dart' as _i28;
import 'package:lantern/replica/ui/viewers/audio.dart' as _i32;
import 'package:lantern/replica/ui/viewers/image.dart' as _i30;
import 'package:lantern/replica/ui/viewers/misc.dart' as _i29;
import 'package:lantern/replica/ui/viewers/video.dart' as _i31;
import 'package:lantern/replica/upload/description.dart' as _i26;
import 'package:lantern/replica/upload/review.dart' as _i27;
import 'package:lantern/replica/upload/title.dart' as _i25;

class AppRouter extends _i33.RootStackRouter {
  AppRouter([_i34.GlobalKey<_i34.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i33.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i33.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i1.HomePage(key: args.key),
      );
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i2.FullScreenDialog(
          widget: args.widget,
          key: args.key,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.slideBottom,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i3.AccountManagement(
          key: args.key,
          isPro: args.isPro,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i4.Settings(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i5.Language(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i6.AuthorizeDeviceForPro(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i7.AuthorizeDeviceViaEmail(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i8.AuthorizeDeviceViaEmailPin(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i9.ApproveDevice(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i10.RecoveryKey(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatNumberRecovery.name: (routeData) {
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i11.ChatNumberRecovery(),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatNumberMessaging.name: (routeData) {
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i12.ChatNumberMessaging(),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i13.Conversation(
          contactId: args.contactId,
          initialScrollIndex: args.initialScrollIndex,
          showContactEditingDialog: args.showContactEditingDialog,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i14.ContactInfo(contact: args.contact),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    NewChat.name: (routeData) {
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i15.NewChat(),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    AddViaChatNumber.name: (routeData) {
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i16.AddViaChatNumber(),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i17.Introduce(
          singleIntro: args.singleIntro,
          contactToIntro: args.contactToIntro,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Introductions.name: (routeData) {
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i18.Introductions(),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatNumberAccount.name: (routeData) {
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i19.ChatNumberAccount(),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i20.BlockedUsers(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Checkout.name: (routeData) {
      final args = routeData.argsAs<CheckoutArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i21.Checkout(
          plans: args.plans,
          id: args.id,
          isPro: args.isPro,
          key: args.key,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ResellerCheckout.name: (routeData) {
      final args = routeData.argsAs<ResellerCheckoutArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i22.ResellerCheckout(
          key: args.key,
          isPro: args.isPro,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    StripeCheckout.name: (routeData) {
      final args = routeData.argsAs<StripeCheckoutArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i23.StripeCheckout(
          plans: args.plans,
          email: args.email,
          refCode: args.refCode,
          id: args.id,
          isPro: args.isPro,
          key: args.key,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    Upgrade.name: (routeData) {
      final args =
          routeData.argsAs<UpgradeArgs>(orElse: () => const UpgradeArgs());
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i24.Upgrade(key: args.key),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaUploadTitle.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadTitleArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i25.ReplicaUploadTitle(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaUploadDescription.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadDescriptionArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i26.ReplicaUploadDescription(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaUploadReview.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadReviewArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i27.ReplicaUploadReview(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaLinkHandler.name: (routeData) {
      final args = routeData.argsAs<ReplicaLinkHandlerArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i28.ReplicaLinkHandler(
          key: args.key,
          replicaApi: args.replicaApi,
          replicaLink: args.replicaLink,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaMiscViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaMiscViewerArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i29.ReplicaMiscViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaImageViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaImageViewerArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i30.ReplicaImageViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaVideoViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaVideoViewerArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i31.ReplicaVideoViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ReplicaAudioViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaAudioViewerArgs>();
      return _i33.CustomPage<void>(
        routeData: routeData,
        child: _i32.ReplicaAudioViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
        transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 200,
        reverseDurationInMilliseconds: 200,
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i33.RouteConfig> get routes => [
        _i33.RouteConfig(
          Home.name,
          path: '/',
        ),
        _i33.RouteConfig(
          FullScreenDialogPage.name,
          path: 'fullScreenDialogPage',
        ),
        _i33.RouteConfig(
          AccountManagement.name,
          path: 'accountManagement',
        ),
        _i33.RouteConfig(
          Settings.name,
          path: 'settings',
        ),
        _i33.RouteConfig(
          Language.name,
          path: 'language',
        ),
        _i33.RouteConfig(
          AuthorizePro.name,
          path: 'authorizePro',
        ),
        _i33.RouteConfig(
          AuthorizeDeviceEmail.name,
          path: 'authorizeDeviceEmail',
        ),
        _i33.RouteConfig(
          AuthorizeDeviceEmailPin.name,
          path: 'authorizeDeviceEmailPin',
        ),
        _i33.RouteConfig(
          ApproveDevice.name,
          path: 'approveDevice',
        ),
        _i33.RouteConfig(
          RecoveryKey.name,
          path: 'recoveryKey',
        ),
        _i33.RouteConfig(
          ChatNumberRecovery.name,
          path: 'chatNumberRecovery',
        ),
        _i33.RouteConfig(
          ChatNumberMessaging.name,
          path: 'chatNumberMessaging',
        ),
        _i33.RouteConfig(
          Conversation.name,
          path: 'conversation',
        ),
        _i33.RouteConfig(
          ContactInfo.name,
          path: 'contactInfo',
        ),
        _i33.RouteConfig(
          NewChat.name,
          path: 'newChat',
        ),
        _i33.RouteConfig(
          AddViaChatNumber.name,
          path: 'addViaChatNumber',
        ),
        _i33.RouteConfig(
          Introduce.name,
          path: 'introduce',
        ),
        _i33.RouteConfig(
          Introductions.name,
          path: 'introductions',
        ),
        _i33.RouteConfig(
          ChatNumberAccount.name,
          path: 'chatNumberAccount',
        ),
        _i33.RouteConfig(
          BlockedUsers.name,
          path: 'blockedUsers',
        ),
        _i33.RouteConfig(
          Checkout.name,
          path: 'checkout',
        ),
        _i33.RouteConfig(
          ResellerCheckout.name,
          path: 'resellerCheckout',
        ),
        _i33.RouteConfig(
          StripeCheckout.name,
          path: 'stripeCheckout',
        ),
        _i33.RouteConfig(
          Upgrade.name,
          path: 'upgrade',
        ),
        _i33.RouteConfig(
          ReplicaUploadTitle.name,
          path: 'replicaUploadTitle',
        ),
        _i33.RouteConfig(
          ReplicaUploadDescription.name,
          path: 'replicaUploadDescription',
        ),
        _i33.RouteConfig(
          ReplicaUploadReview.name,
          path: 'replicaUploadReview',
        ),
        _i33.RouteConfig(
          ReplicaLinkHandler.name,
          path: 'replicaLinkHandler',
        ),
        _i33.RouteConfig(
          ReplicaMiscViewer.name,
          path: 'replicaMiscViewer',
        ),
        _i33.RouteConfig(
          ReplicaImageViewer.name,
          path: 'replicaImageViewer',
        ),
        _i33.RouteConfig(
          ReplicaVideoViewer.name,
          path: 'replicaVideoViewer',
        ),
        _i33.RouteConfig(
          ReplicaAudioViewer.name,
          path: 'replicaAudioViewer',
        ),
      ];
}

/// generated route for
/// [_i1.HomePage]
class Home extends _i33.PageRouteInfo<HomeArgs> {
  Home({_i35.Key? key})
      : super(
          Home.name,
          path: '/',
          args: HomeArgs(key: key),
        );

  static const String name = 'Home';
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'HomeArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.FullScreenDialog]
class FullScreenDialogPage
    extends _i33.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({
    required _i35.Widget widget,
    _i35.Key? key,
  }) : super(
          FullScreenDialogPage.name,
          path: 'fullScreenDialogPage',
          args: FullScreenDialogPageArgs(
            widget: widget,
            key: key,
          ),
        );

  static const String name = 'FullScreenDialogPage';
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({
    required this.widget,
    this.key,
  });

  final _i35.Widget widget;

  final _i35.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for
/// [_i3.AccountManagement]
class AccountManagement extends _i33.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({
    _i35.Key? key,
    required bool isPro,
  }) : super(
          AccountManagement.name,
          path: 'accountManagement',
          args: AccountManagementArgs(
            key: key,
            isPro: isPro,
          ),
        );

  static const String name = 'AccountManagement';
}

class AccountManagementArgs {
  const AccountManagementArgs({
    this.key,
    required this.isPro,
  });

  final _i35.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for
/// [_i4.Settings]
class Settings extends _i33.PageRouteInfo<SettingsArgs> {
  Settings({_i35.Key? key})
      : super(
          Settings.name,
          path: 'settings',
          args: SettingsArgs(key: key),
        );

  static const String name = 'Settings';
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'SettingsArgs{key: $key}';
  }
}

/// generated route for
/// [_i5.Language]
class Language extends _i33.PageRouteInfo<LanguageArgs> {
  Language({_i35.Key? key})
      : super(
          Language.name,
          path: 'language',
          args: LanguageArgs(key: key),
        );

  static const String name = 'Language';
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'LanguageArgs{key: $key}';
  }
}

/// generated route for
/// [_i6.AuthorizeDeviceForPro]
class AuthorizePro extends _i33.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i35.Key? key})
      : super(
          AuthorizePro.name,
          path: 'authorizePro',
          args: AuthorizeProArgs(key: key),
        );

  static const String name = 'AuthorizePro';
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'AuthorizeProArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i33.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i35.Key? key})
      : super(
          AuthorizeDeviceEmail.name,
          path: 'authorizeDeviceEmail',
          args: AuthorizeDeviceEmailArgs(key: key),
        );

  static const String name = 'AuthorizeDeviceEmail';
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailArgs{key: $key}';
  }
}

/// generated route for
/// [_i8.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i33.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i35.Key? key})
      : super(
          AuthorizeDeviceEmailPin.name,
          path: 'authorizeDeviceEmailPin',
          args: AuthorizeDeviceEmailPinArgs(key: key),
        );

  static const String name = 'AuthorizeDeviceEmailPin';
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailPinArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.ApproveDevice]
class ApproveDevice extends _i33.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i35.Key? key})
      : super(
          ApproveDevice.name,
          path: 'approveDevice',
          args: ApproveDeviceArgs(key: key),
        );

  static const String name = 'ApproveDevice';
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'ApproveDeviceArgs{key: $key}';
  }
}

/// generated route for
/// [_i10.RecoveryKey]
class RecoveryKey extends _i33.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({_i35.Key? key})
      : super(
          RecoveryKey.name,
          path: 'recoveryKey',
          args: RecoveryKeyArgs(key: key),
        );

  static const String name = 'RecoveryKey';
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'RecoveryKeyArgs{key: $key}';
  }
}

/// generated route for
/// [_i11.ChatNumberRecovery]
class ChatNumberRecovery extends _i33.PageRouteInfo<void> {
  const ChatNumberRecovery()
      : super(
          ChatNumberRecovery.name,
          path: 'chatNumberRecovery',
        );

  static const String name = 'ChatNumberRecovery';
}

/// generated route for
/// [_i12.ChatNumberMessaging]
class ChatNumberMessaging extends _i33.PageRouteInfo<void> {
  const ChatNumberMessaging()
      : super(
          ChatNumberMessaging.name,
          path: 'chatNumberMessaging',
        );

  static const String name = 'ChatNumberMessaging';
}

/// generated route for
/// [_i13.Conversation]
class Conversation extends _i33.PageRouteInfo<ConversationArgs> {
  Conversation({
    required _i35.ContactId contactId,
    int? initialScrollIndex,
    bool showContactEditingDialog = false,
  }) : super(
          Conversation.name,
          path: 'conversation',
          args: ConversationArgs(
            contactId: contactId,
            initialScrollIndex: initialScrollIndex,
            showContactEditingDialog: showContactEditingDialog,
          ),
        );

  static const String name = 'Conversation';
}

class ConversationArgs {
  const ConversationArgs({
    required this.contactId,
    this.initialScrollIndex,
    this.showContactEditingDialog = false,
  });

  final _i35.ContactId contactId;

  final int? initialScrollIndex;

  final bool showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

/// generated route for
/// [_i14.ContactInfo]
class ContactInfo extends _i33.PageRouteInfo<ContactInfoArgs> {
  ContactInfo({required _i35.Contact contact})
      : super(
          ContactInfo.name,
          path: 'contactInfo',
          args: ContactInfoArgs(contact: contact),
        );

  static const String name = 'ContactInfo';
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.contact});

  final _i35.Contact contact;

  @override
  String toString() {
    return 'ContactInfoArgs{contact: $contact}';
  }
}

/// generated route for
/// [_i15.NewChat]
class NewChat extends _i33.PageRouteInfo<void> {
  const NewChat()
      : super(
          NewChat.name,
          path: 'newChat',
        );

  static const String name = 'NewChat';
}

/// generated route for
/// [_i16.AddViaChatNumber]
class AddViaChatNumber extends _i33.PageRouteInfo<void> {
  const AddViaChatNumber()
      : super(
          AddViaChatNumber.name,
          path: 'addViaChatNumber',
        );

  static const String name = 'AddViaChatNumber';
}

/// generated route for
/// [_i17.Introduce]
class Introduce extends _i33.PageRouteInfo<IntroduceArgs> {
  Introduce({
    required bool singleIntro,
    _i35.Contact? contactToIntro,
  }) : super(
          Introduce.name,
          path: 'introduce',
          args: IntroduceArgs(
            singleIntro: singleIntro,
            contactToIntro: contactToIntro,
          ),
        );

  static const String name = 'Introduce';
}

class IntroduceArgs {
  const IntroduceArgs({
    required this.singleIntro,
    this.contactToIntro,
  });

  final bool singleIntro;

  final _i35.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for
/// [_i18.Introductions]
class Introductions extends _i33.PageRouteInfo<void> {
  const Introductions()
      : super(
          Introductions.name,
          path: 'introductions',
        );

  static const String name = 'Introductions';
}

/// generated route for
/// [_i19.ChatNumberAccount]
class ChatNumberAccount extends _i33.PageRouteInfo<void> {
  const ChatNumberAccount()
      : super(
          ChatNumberAccount.name,
          path: 'chatNumberAccount',
        );

  static const String name = 'ChatNumberAccount';
}

/// generated route for
/// [_i20.BlockedUsers]
class BlockedUsers extends _i33.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({_i35.Key? key})
      : super(
          BlockedUsers.name,
          path: 'blockedUsers',
          args: BlockedUsersArgs(key: key),
        );

  static const String name = 'BlockedUsers';
}

class BlockedUsersArgs {
  const BlockedUsersArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'BlockedUsersArgs{key: $key}';
  }
}

/// generated route for
/// [_i21.Checkout]
class Checkout extends _i33.PageRouteInfo<CheckoutArgs> {
  Checkout({
    required List<_i35.Plan> plans,
    required String id,
    required bool isPro,
    _i35.Key? key,
  }) : super(
          Checkout.name,
          path: 'checkout',
          args: CheckoutArgs(
            plans: plans,
            id: id,
            isPro: isPro,
            key: key,
          ),
        );

  static const String name = 'Checkout';
}

class CheckoutArgs {
  const CheckoutArgs({
    required this.plans,
    required this.id,
    required this.isPro,
    this.key,
  });

  final List<_i35.Plan> plans;

  final String id;

  final bool isPro;

  final _i35.Key? key;

  @override
  String toString() {
    return 'CheckoutArgs{plans: $plans, id: $id, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i22.ResellerCheckout]
class ResellerCheckout extends _i33.PageRouteInfo<ResellerCheckoutArgs> {
  ResellerCheckout({
    _i35.Key? key,
    required bool isPro,
  }) : super(
          ResellerCheckout.name,
          path: 'resellerCheckout',
          args: ResellerCheckoutArgs(
            key: key,
            isPro: isPro,
          ),
        );

  static const String name = 'ResellerCheckout';
}

class ResellerCheckoutArgs {
  const ResellerCheckoutArgs({
    this.key,
    required this.isPro,
  });

  final _i35.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'ResellerCheckoutArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for
/// [_i23.StripeCheckout]
class StripeCheckout extends _i33.PageRouteInfo<StripeCheckoutArgs> {
  StripeCheckout({
    required List<_i35.Plan> plans,
    required String email,
    String? refCode,
    required String id,
    required bool isPro,
    _i35.Key? key,
  }) : super(
          StripeCheckout.name,
          path: 'stripeCheckout',
          args: StripeCheckoutArgs(
            plans: plans,
            email: email,
            refCode: refCode,
            id: id,
            isPro: isPro,
            key: key,
          ),
        );

  static const String name = 'StripeCheckout';
}

class StripeCheckoutArgs {
  const StripeCheckoutArgs({
    required this.plans,
    required this.email,
    this.refCode,
    required this.id,
    required this.isPro,
    this.key,
  });

  final List<_i35.Plan> plans;

  final String email;

  final String? refCode;

  final String id;

  final bool isPro;

  final _i35.Key? key;

  @override
  String toString() {
    return 'StripeCheckoutArgs{plans: $plans, email: $email, refCode: $refCode, id: $id, isPro: $isPro, key: $key}';
  }
}

/// generated route for
/// [_i24.Upgrade]
class Upgrade extends _i33.PageRouteInfo<UpgradeArgs> {
  Upgrade({_i35.Key? key})
      : super(
          Upgrade.name,
          path: 'upgrade',
          args: UpgradeArgs(key: key),
        );

  static const String name = 'Upgrade';
}

class UpgradeArgs {
  const UpgradeArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'UpgradeArgs{key: $key}';
  }
}

/// generated route for
/// [_i25.ReplicaUploadTitle]
class ReplicaUploadTitle extends _i33.PageRouteInfo<ReplicaUploadTitleArgs> {
  ReplicaUploadTitle({
    _i35.Key? key,
    required _i36.File fileToUpload,
    String? fileTitle,
    String? fileDescription,
  }) : super(
          ReplicaUploadTitle.name,
          path: 'replicaUploadTitle',
          args: ReplicaUploadTitleArgs(
            key: key,
            fileToUpload: fileToUpload,
            fileTitle: fileTitle,
            fileDescription: fileDescription,
          ),
        );

  static const String name = 'ReplicaUploadTitle';
}

class ReplicaUploadTitleArgs {
  const ReplicaUploadTitleArgs({
    this.key,
    required this.fileToUpload,
    this.fileTitle,
    this.fileDescription,
  });

  final _i35.Key? key;

  final _i36.File fileToUpload;

  final String? fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadTitleArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i26.ReplicaUploadDescription]
class ReplicaUploadDescription
    extends _i33.PageRouteInfo<ReplicaUploadDescriptionArgs> {
  ReplicaUploadDescription({
    _i35.Key? key,
    required _i36.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
  }) : super(
          ReplicaUploadDescription.name,
          path: 'replicaUploadDescription',
          args: ReplicaUploadDescriptionArgs(
            key: key,
            fileToUpload: fileToUpload,
            fileTitle: fileTitle,
            fileDescription: fileDescription,
          ),
        );

  static const String name = 'ReplicaUploadDescription';
}

class ReplicaUploadDescriptionArgs {
  const ReplicaUploadDescriptionArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i35.Key? key;

  final _i36.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadDescriptionArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i27.ReplicaUploadReview]
class ReplicaUploadReview extends _i33.PageRouteInfo<ReplicaUploadReviewArgs> {
  ReplicaUploadReview({
    _i35.Key? key,
    required _i36.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
  }) : super(
          ReplicaUploadReview.name,
          path: 'replicaUploadReview',
          args: ReplicaUploadReviewArgs(
            key: key,
            fileToUpload: fileToUpload,
            fileTitle: fileTitle,
            fileDescription: fileDescription,
          ),
        );

  static const String name = 'ReplicaUploadReview';
}

class ReplicaUploadReviewArgs {
  const ReplicaUploadReviewArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i35.Key? key;

  final _i36.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadReviewArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i28.ReplicaLinkHandler]
class ReplicaLinkHandler extends _i33.PageRouteInfo<ReplicaLinkHandlerArgs> {
  ReplicaLinkHandler({
    _i35.Key? key,
    required _i37.ReplicaApi replicaApi,
    required _i37.ReplicaLink replicaLink,
  }) : super(
          ReplicaLinkHandler.name,
          path: 'replicaLinkHandler',
          args: ReplicaLinkHandlerArgs(
            key: key,
            replicaApi: replicaApi,
            replicaLink: replicaLink,
          ),
        );

  static const String name = 'ReplicaLinkHandler';
}

class ReplicaLinkHandlerArgs {
  const ReplicaLinkHandlerArgs({
    this.key,
    required this.replicaApi,
    required this.replicaLink,
  });

  final _i35.Key? key;

  final _i37.ReplicaApi replicaApi;

  final _i37.ReplicaLink replicaLink;

  @override
  String toString() {
    return 'ReplicaLinkHandlerArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink}';
  }
}

/// generated route for
/// [_i29.ReplicaMiscViewer]
class ReplicaMiscViewer extends _i33.PageRouteInfo<ReplicaMiscViewerArgs> {
  ReplicaMiscViewer({
    required _i37.ReplicaApi replicaApi,
    required _i37.ReplicaSearchItem item,
    required _i37.SearchCategory category,
  }) : super(
          ReplicaMiscViewer.name,
          path: 'replicaMiscViewer',
          args: ReplicaMiscViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
        );

  static const String name = 'ReplicaMiscViewer';
}

class ReplicaMiscViewerArgs {
  const ReplicaMiscViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i37.ReplicaApi replicaApi;

  final _i37.ReplicaSearchItem item;

  final _i37.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaMiscViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i30.ReplicaImageViewer]
class ReplicaImageViewer extends _i33.PageRouteInfo<ReplicaImageViewerArgs> {
  ReplicaImageViewer({
    required _i37.ReplicaApi replicaApi,
    required _i37.ReplicaSearchItem item,
    required _i37.SearchCategory category,
  }) : super(
          ReplicaImageViewer.name,
          path: 'replicaImageViewer',
          args: ReplicaImageViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
        );

  static const String name = 'ReplicaImageViewer';
}

class ReplicaImageViewerArgs {
  const ReplicaImageViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i37.ReplicaApi replicaApi;

  final _i37.ReplicaSearchItem item;

  final _i37.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaImageViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i31.ReplicaVideoViewer]
class ReplicaVideoViewer extends _i33.PageRouteInfo<ReplicaVideoViewerArgs> {
  ReplicaVideoViewer({
    required _i37.ReplicaApi replicaApi,
    required _i37.ReplicaSearchItem item,
    required _i37.SearchCategory category,
  }) : super(
          ReplicaVideoViewer.name,
          path: 'replicaVideoViewer',
          args: ReplicaVideoViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
        );

  static const String name = 'ReplicaVideoViewer';
}

class ReplicaVideoViewerArgs {
  const ReplicaVideoViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i37.ReplicaApi replicaApi;

  final _i37.ReplicaSearchItem item;

  final _i37.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaVideoViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i32.ReplicaAudioViewer]
class ReplicaAudioViewer extends _i33.PageRouteInfo<ReplicaAudioViewerArgs> {
  ReplicaAudioViewer({
    required _i37.ReplicaApi replicaApi,
    required _i37.ReplicaSearchItem item,
    required _i37.SearchCategory category,
  }) : super(
          ReplicaAudioViewer.name,
          path: 'replicaAudioViewer',
          args: ReplicaAudioViewerArgs(
            replicaApi: replicaApi,
            item: item,
            category: category,
          ),
        );

  static const String name = 'ReplicaAudioViewer';
}

class ReplicaAudioViewerArgs {
  const ReplicaAudioViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i37.ReplicaApi replicaApi;

  final _i37.ReplicaSearchItem item;

  final _i37.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaAudioViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

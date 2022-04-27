// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i33;
import 'package:flutter/material.dart' as _i34;
import 'package:lantern/account/account_management.dart' as _i11;
import 'package:lantern/account/blocked_users.dart' as _i24;
import 'package:lantern/account/chat_number_account.dart' as _i23;
import 'package:lantern/account/device_linking/approve_device.dart' as _i21;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i17;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i19;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i20;
import 'package:lantern/account/language.dart' as _i15;
import 'package:lantern/account/plans/activation_code_checkout.dart' as _i32;
import 'package:lantern/account/plans/checkout.dart' as _i30;
import 'package:lantern/account/plans/stripe_checkout.dart' as _i31;
import 'package:lantern/account/plans/upgrade.dart' as _i29;
import 'package:lantern/account/recovery_key.dart' as _i22;
import 'package:lantern/account/settings.dart' as _i13;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i4;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i8;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i6;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i7;
import 'package:lantern/messaging/conversation/conversation.dart' as _i5;
import 'package:lantern/messaging/introductions/introduce.dart' as _i9;
import 'package:lantern/messaging/introductions/introductions.dart' as _i10;
import 'package:lantern/messaging/messaging.dart' as _i35;
import 'package:lantern/messaging/onboarding/chat_number_messaging.dart' as _i3;
import 'package:lantern/messaging/onboarding/chat_number_recovery.dart' as _i2;
import 'package:lantern/replica/logic/api.dart' as _i36;
import 'package:lantern/replica/models/replica_link.dart' as _i37;
import 'package:lantern/replica/models/searchcategory.dart' as _i38;
import 'package:lantern/replica/ui/link_opener_screen.dart' as _i12;
import 'package:lantern/replica/ui/media_views/audio_player_screen.dart'
    as _i16;
import 'package:lantern/replica/ui/media_views/image_preview_screen.dart'
    as _i18;
import 'package:lantern/replica/ui/media_views/pdf_screen.dart' as _i25;
import 'package:lantern/replica/ui/media_views/unknown_item_screen.dart'
    as _i26;
import 'package:lantern/replica/ui/media_views/video_player_screen.dart'
    as _i14;
import 'package:lantern/replica/ui/search_screen.dart' as _i27;
import 'package:lantern/replica/ui/upload_file.dart' as _i28;

class AppRouter extends _i33.RootStackRouter {
  AppRouter([_i34.GlobalKey<_i34.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i33.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i33.AdaptivePage<dynamic>(
          routeData: routeData, child: _i1.HomePage(key: args.key));
    },
    ChatNumberRecovery.name: (routeData) {
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i2.ChatNumberRecovery(),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ChatNumberMessaging.name: (routeData) {
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i3.ChatNumberMessaging(),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i4.FullScreenDialog(widget: args.widget, key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.slideBottom,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i5.Conversation(
              contactId: args.contactId,
              initialScrollIndex: args.initialScrollIndex,
              showContactEditingDialog: args.showContactEditingDialog),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i6.ContactInfo(contact: args.contact),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    NewChat.name: (routeData) {
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i7.NewChat(),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AddViaChatNumber.name: (routeData) {
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i8.AddViaChatNumber(),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i9.Introduce(
              singleIntro: args.singleIntro,
              contactToIntro: args.contactToIntro),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introductions.name: (routeData) {
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i10.Introductions(),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i11.AccountManagement(key: args.key, isPro: args.isPro),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaLinkOpenerScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaLinkOpenerScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i12.ReplicaLinkOpenerScreen(
              key: args.key,
              replicaApi: args.replicaApi,
              replicaLink: args.replicaLink),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i13.Settings(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaVideoPlayerScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaVideoPlayerScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i14.ReplicaVideoPlayerScreen(
              key: args.key,
              replicaApi: args.replicaApi,
              replicaLink: args.replicaLink,
              mimeType: args.mimeType),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i15.Language(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaAudioPlayerScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaAudioPlayerScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i16.ReplicaAudioPlayerScreen(
              key: args.key,
              replicaApi: args.replicaApi,
              replicaLink: args.replicaLink,
              mimeType: args.mimeType),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i17.AuthorizeDeviceForPro(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaImagePreviewScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaImagePreviewScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i18.ReplicaImagePreviewScreen(
              key: args.key, replicaLink: args.replicaLink),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i19.AuthorizeDeviceViaEmail(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i20.AuthorizeDeviceViaEmailPin(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i21.ApproveDevice(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i22.RecoveryKey(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ChatNumberAccount.name: (routeData) {
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i23.ChatNumberAccount(),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i24.BlockedUsers(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaPDFScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaPDFScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i25.ReplicaPDFScreen(
              key: args.key,
              replicaApi: args.replicaApi,
              replicaLink: args.replicaLink,
              category: args.category,
              mimeType: args.mimeType),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaUnknownItemScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaUnknownItemScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i26.ReplicaUnknownItemScreen(
              key: args.key,
              replicaLink: args.replicaLink,
              category: args.category,
              mimeType: args.mimeType),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaSearchScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaSearchScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i27.ReplicaSearchScreen(
              key: args.key, searchQuery: args.searchQuery),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ReplicaUploadFileScreen.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadFileScreenArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i28.ReplicaUploadFileScreen(
              key: args.key, fileToUpload: args.fileToUpload),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Upgrade.name: (routeData) {
      final args =
          routeData.argsAs<UpgradeArgs>(orElse: () => const UpgradeArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i29.Upgrade(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Checkout.name: (routeData) {
      final args = routeData.argsAs<CheckoutArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i30.Checkout(id: args.id, key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    StripeCheckout.name: (routeData) {
      final args = routeData.argsAs<StripeCheckoutArgs>();
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i31.StripeCheckout(
              email: args.email,
              refCode: args.refCode,
              id: args.id,
              key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ActivationCodeCheckout.name: (routeData) {
      final args = routeData.argsAs<ActivationCodeCheckoutArgs>(
          orElse: () => const ActivationCodeCheckoutArgs());
      return _i33.CustomPage<void>(
          routeData: routeData,
          child: _i32.ActivationCodeCheckout(key: args.key),
          transitionsBuilder: _i33.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i33.RouteConfig> get routes => [
        _i33.RouteConfig(Home.name, path: '/'),
        _i33.RouteConfig(ChatNumberRecovery.name, path: 'chatNumberRecovery'),
        _i33.RouteConfig(ChatNumberMessaging.name, path: 'chatNumberMessaging'),
        _i33.RouteConfig(FullScreenDialogPage.name,
            path: 'fullScreenDialogPage'),
        _i33.RouteConfig(Conversation.name, path: 'conversation'),
        _i33.RouteConfig(ContactInfo.name, path: 'contactInfo'),
        _i33.RouteConfig(NewChat.name, path: 'newChat'),
        _i33.RouteConfig(AddViaChatNumber.name, path: 'addViaChatNumber'),
        _i33.RouteConfig(Introduce.name, path: 'introduce'),
        _i33.RouteConfig(Introductions.name, path: 'introductions'),
        _i33.RouteConfig(AccountManagement.name, path: 'accountManagement'),
        _i33.RouteConfig(ReplicaLinkOpenerScreen.name,
            path: 'replicaLinkOpenerScreen'),
        _i33.RouteConfig(Settings.name, path: 'settings'),
        _i33.RouteConfig(ReplicaVideoPlayerScreen.name,
            path: 'replicaVideoPlayerScreen'),
        _i33.RouteConfig(Language.name, path: 'language'),
        _i33.RouteConfig(ReplicaAudioPlayerScreen.name,
            path: 'replicaAudioPlayerScreen'),
        _i33.RouteConfig(AuthorizePro.name, path: 'authorizePro'),
        _i33.RouteConfig(ReplicaImagePreviewScreen.name,
            path: 'replicaImagePreviewScreen'),
        _i33.RouteConfig(AuthorizeDeviceEmail.name,
            path: 'authorizeDeviceEmail'),
        _i33.RouteConfig(AuthorizeDeviceEmailPin.name,
            path: 'authorizeDeviceEmailPin'),
        _i33.RouteConfig(ApproveDevice.name, path: 'approveDevice'),
        _i33.RouteConfig(RecoveryKey.name, path: 'recoveryKey'),
        _i33.RouteConfig(ChatNumberAccount.name, path: 'chatNumberAccount'),
        _i33.RouteConfig(BlockedUsers.name, path: 'blockedUsers'),
        _i33.RouteConfig(ReplicaPDFScreen.name, path: 'replicaPDFScreen'),
        _i33.RouteConfig(ReplicaUnknownItemScreen.name,
            path: 'replicaUnknownItemScreen'),
        _i33.RouteConfig(ReplicaSearchScreen.name, path: 'replicaSearchScreen'),
        _i33.RouteConfig(ReplicaUploadFileScreen.name,
            path: 'replicaUploadFileScreen'),
        _i33.RouteConfig(Upgrade.name, path: 'upgrade'),
        _i33.RouteConfig(Checkout.name, path: 'checkout'),
        _i33.RouteConfig(StripeCheckout.name, path: 'stripeCheckout'),
        _i33.RouteConfig(ActivationCodeCheckout.name,
            path: 'activationCodeCheckout')
      ];
}

/// generated route for
/// [_i1.HomePage]
class Home extends _i33.PageRouteInfo<HomeArgs> {
  Home({_i35.Key? key}) : super(Home.name, path: '/', args: HomeArgs(key: key));

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
/// [_i2.ChatNumberRecovery]
class ChatNumberRecovery extends _i33.PageRouteInfo<void> {
  const ChatNumberRecovery()
      : super(ChatNumberRecovery.name, path: 'chatNumberRecovery');

  static const String name = 'ChatNumberRecovery';
}

/// generated route for
/// [_i3.ChatNumberMessaging]
class ChatNumberMessaging extends _i33.PageRouteInfo<void> {
  const ChatNumberMessaging()
      : super(ChatNumberMessaging.name, path: 'chatNumberMessaging');

  static const String name = 'ChatNumberMessaging';
}

/// generated route for
/// [_i4.FullScreenDialog]
class FullScreenDialogPage
    extends _i33.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({required _i35.Widget widget, _i35.Key? key})
      : super(FullScreenDialogPage.name,
            path: 'fullScreenDialogPage',
            args: FullScreenDialogPageArgs(widget: widget, key: key));

  static const String name = 'FullScreenDialogPage';
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({required this.widget, this.key});

  final _i35.Widget widget;

  final _i35.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for
/// [_i5.Conversation]
class Conversation extends _i33.PageRouteInfo<ConversationArgs> {
  Conversation(
      {required _i35.ContactId contactId,
      int? initialScrollIndex,
      bool showContactEditingDialog = false})
      : super(Conversation.name,
            path: 'conversation',
            args: ConversationArgs(
                contactId: contactId,
                initialScrollIndex: initialScrollIndex,
                showContactEditingDialog: showContactEditingDialog));

  static const String name = 'Conversation';
}

class ConversationArgs {
  const ConversationArgs(
      {required this.contactId,
      this.initialScrollIndex,
      this.showContactEditingDialog = false});

  final _i35.ContactId contactId;

  final int? initialScrollIndex;

  final bool showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

/// generated route for
/// [_i6.ContactInfo]
class ContactInfo extends _i33.PageRouteInfo<ContactInfoArgs> {
  ContactInfo({required _i35.Contact contact})
      : super(ContactInfo.name,
            path: 'contactInfo', args: ContactInfoArgs(contact: contact));

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
/// [_i7.NewChat]
class NewChat extends _i33.PageRouteInfo<void> {
  const NewChat() : super(NewChat.name, path: 'newChat');

  static const String name = 'NewChat';
}

/// generated route for
/// [_i8.AddViaChatNumber]
class AddViaChatNumber extends _i33.PageRouteInfo<void> {
  const AddViaChatNumber()
      : super(AddViaChatNumber.name, path: 'addViaChatNumber');

  static const String name = 'AddViaChatNumber';
}

/// generated route for
/// [_i9.Introduce]
class Introduce extends _i33.PageRouteInfo<IntroduceArgs> {
  Introduce({required bool singleIntro, _i35.Contact? contactToIntro})
      : super(Introduce.name,
            path: 'introduce',
            args: IntroduceArgs(
                singleIntro: singleIntro, contactToIntro: contactToIntro));

  static const String name = 'Introduce';
}

class IntroduceArgs {
  const IntroduceArgs({required this.singleIntro, this.contactToIntro});

  final bool singleIntro;

  final _i35.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for
/// [_i10.Introductions]
class Introductions extends _i33.PageRouteInfo<void> {
  const Introductions() : super(Introductions.name, path: 'introductions');

  static const String name = 'Introductions';
}

/// generated route for
/// [_i11.AccountManagement]
class AccountManagement extends _i33.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({_i35.Key? key, required bool isPro})
      : super(AccountManagement.name,
            path: 'accountManagement',
            args: AccountManagementArgs(key: key, isPro: isPro));

  static const String name = 'AccountManagement';
}

class AccountManagementArgs {
  const AccountManagementArgs({this.key, required this.isPro});

  final _i35.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for
/// [_i12.ReplicaLinkOpenerScreen]
class ReplicaLinkOpenerScreen
    extends _i33.PageRouteInfo<ReplicaLinkOpenerScreenArgs> {
  ReplicaLinkOpenerScreen(
      {_i35.Key? key,
      required _i36.ReplicaApi replicaApi,
      required _i37.ReplicaLink replicaLink})
      : super(ReplicaLinkOpenerScreen.name,
            path: 'replicaLinkOpenerScreen',
            args: ReplicaLinkOpenerScreenArgs(
                key: key, replicaApi: replicaApi, replicaLink: replicaLink));

  static const String name = 'ReplicaLinkOpenerScreen';
}

class ReplicaLinkOpenerScreenArgs {
  const ReplicaLinkOpenerScreenArgs(
      {this.key, required this.replicaApi, required this.replicaLink});

  final _i35.Key? key;

  final _i36.ReplicaApi replicaApi;

  final _i37.ReplicaLink replicaLink;

  @override
  String toString() {
    return 'ReplicaLinkOpenerScreenArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink}';
  }
}

/// generated route for
/// [_i13.Settings]
class Settings extends _i33.PageRouteInfo<SettingsArgs> {
  Settings({_i35.Key? key})
      : super(Settings.name, path: 'settings', args: SettingsArgs(key: key));

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
/// [_i14.ReplicaVideoPlayerScreen]
class ReplicaVideoPlayerScreen
    extends _i33.PageRouteInfo<ReplicaVideoPlayerScreenArgs> {
  ReplicaVideoPlayerScreen(
      {_i35.Key? key,
      required _i36.ReplicaApi replicaApi,
      required _i37.ReplicaLink replicaLink,
      String? mimeType})
      : super(ReplicaVideoPlayerScreen.name,
            path: 'replicaVideoPlayerScreen',
            args: ReplicaVideoPlayerScreenArgs(
                key: key,
                replicaApi: replicaApi,
                replicaLink: replicaLink,
                mimeType: mimeType));

  static const String name = 'ReplicaVideoPlayerScreen';
}

class ReplicaVideoPlayerScreenArgs {
  const ReplicaVideoPlayerScreenArgs(
      {this.key,
      required this.replicaApi,
      required this.replicaLink,
      this.mimeType});

  final _i35.Key? key;

  final _i36.ReplicaApi replicaApi;

  final _i37.ReplicaLink replicaLink;

  final String? mimeType;

  @override
  String toString() {
    return 'ReplicaVideoPlayerScreenArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink, mimeType: $mimeType}';
  }
}

/// generated route for
/// [_i15.Language]
class Language extends _i33.PageRouteInfo<LanguageArgs> {
  Language({_i35.Key? key})
      : super(Language.name, path: 'language', args: LanguageArgs(key: key));

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
/// [_i16.ReplicaAudioPlayerScreen]
class ReplicaAudioPlayerScreen
    extends _i33.PageRouteInfo<ReplicaAudioPlayerScreenArgs> {
  ReplicaAudioPlayerScreen(
      {_i35.Key? key,
      required _i36.ReplicaApi replicaApi,
      required _i37.ReplicaLink replicaLink,
      String? mimeType})
      : super(ReplicaAudioPlayerScreen.name,
            path: 'replicaAudioPlayerScreen',
            args: ReplicaAudioPlayerScreenArgs(
                key: key,
                replicaApi: replicaApi,
                replicaLink: replicaLink,
                mimeType: mimeType));

  static const String name = 'ReplicaAudioPlayerScreen';
}

class ReplicaAudioPlayerScreenArgs {
  const ReplicaAudioPlayerScreenArgs(
      {this.key,
      required this.replicaApi,
      required this.replicaLink,
      this.mimeType});

  final _i35.Key? key;

  final _i36.ReplicaApi replicaApi;

  final _i37.ReplicaLink replicaLink;

  final String? mimeType;

  @override
  String toString() {
    return 'ReplicaAudioPlayerScreenArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink, mimeType: $mimeType}';
  }
}

/// generated route for
/// [_i17.AuthorizeDeviceForPro]
class AuthorizePro extends _i33.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i35.Key? key})
      : super(AuthorizePro.name,
            path: 'authorizePro', args: AuthorizeProArgs(key: key));

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
/// [_i18.ReplicaImagePreviewScreen]
class ReplicaImagePreviewScreen
    extends _i33.PageRouteInfo<ReplicaImagePreviewScreenArgs> {
  ReplicaImagePreviewScreen(
      {_i35.Key? key, required _i37.ReplicaLink replicaLink})
      : super(ReplicaImagePreviewScreen.name,
            path: 'replicaImagePreviewScreen',
            args: ReplicaImagePreviewScreenArgs(
                key: key, replicaLink: replicaLink));

  static const String name = 'ReplicaImagePreviewScreen';
}

class ReplicaImagePreviewScreenArgs {
  const ReplicaImagePreviewScreenArgs({this.key, required this.replicaLink});

  final _i35.Key? key;

  final _i37.ReplicaLink replicaLink;

  @override
  String toString() {
    return 'ReplicaImagePreviewScreenArgs{key: $key, replicaLink: $replicaLink}';
  }
}

/// generated route for
/// [_i19.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i33.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i35.Key? key})
      : super(AuthorizeDeviceEmail.name,
            path: 'authorizeDeviceEmail',
            args: AuthorizeDeviceEmailArgs(key: key));

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
/// [_i20.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i33.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i35.Key? key})
      : super(AuthorizeDeviceEmailPin.name,
            path: 'authorizeDeviceEmailPin',
            args: AuthorizeDeviceEmailPinArgs(key: key));

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
/// [_i21.ApproveDevice]
class ApproveDevice extends _i33.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i35.Key? key})
      : super(ApproveDevice.name,
            path: 'approveDevice', args: ApproveDeviceArgs(key: key));

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
/// [_i22.RecoveryKey]
class RecoveryKey extends _i33.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({_i35.Key? key})
      : super(RecoveryKey.name,
            path: 'recoveryKey', args: RecoveryKeyArgs(key: key));

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
/// [_i23.ChatNumberAccount]
class ChatNumberAccount extends _i33.PageRouteInfo<void> {
  const ChatNumberAccount()
      : super(ChatNumberAccount.name, path: 'chatNumberAccount');

  static const String name = 'ChatNumberAccount';
}

/// generated route for
/// [_i24.BlockedUsers]
class BlockedUsers extends _i33.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({_i35.Key? key})
      : super(BlockedUsers.name,
            path: 'blockedUsers', args: BlockedUsersArgs(key: key));

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
/// [_i25.ReplicaPDFScreen]
class ReplicaPDFScreen extends _i33.PageRouteInfo<ReplicaPDFScreenArgs> {
  ReplicaPDFScreen(
      {_i35.Key? key,
      required _i36.ReplicaApi replicaApi,
      required _i37.ReplicaLink replicaLink,
      required _i38.SearchCategory category,
      String? mimeType})
      : super(ReplicaPDFScreen.name,
            path: 'replicaPDFScreen',
            args: ReplicaPDFScreenArgs(
                key: key,
                replicaApi: replicaApi,
                replicaLink: replicaLink,
                category: category,
                mimeType: mimeType));

  static const String name = 'ReplicaPDFScreen';
}

class ReplicaPDFScreenArgs {
  const ReplicaPDFScreenArgs(
      {this.key,
      required this.replicaApi,
      required this.replicaLink,
      required this.category,
      this.mimeType});

  final _i35.Key? key;

  final _i36.ReplicaApi replicaApi;

  final _i37.ReplicaLink replicaLink;

  final _i38.SearchCategory category;

  final String? mimeType;

  @override
  String toString() {
    return 'ReplicaPDFScreenArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink, category: $category, mimeType: $mimeType}';
  }
}

/// generated route for
/// [_i26.ReplicaUnknownItemScreen]
class ReplicaUnknownItemScreen
    extends _i33.PageRouteInfo<ReplicaUnknownItemScreenArgs> {
  ReplicaUnknownItemScreen(
      {_i35.Key? key,
      required _i37.ReplicaLink replicaLink,
      required _i38.SearchCategory category,
      String? mimeType})
      : super(ReplicaUnknownItemScreen.name,
            path: 'replicaUnknownItemScreen',
            args: ReplicaUnknownItemScreenArgs(
                key: key,
                replicaLink: replicaLink,
                category: category,
                mimeType: mimeType));

  static const String name = 'ReplicaUnknownItemScreen';
}

class ReplicaUnknownItemScreenArgs {
  const ReplicaUnknownItemScreenArgs(
      {this.key,
      required this.replicaLink,
      required this.category,
      this.mimeType});

  final _i35.Key? key;

  final _i37.ReplicaLink replicaLink;

  final _i38.SearchCategory category;

  final String? mimeType;

  @override
  String toString() {
    return 'ReplicaUnknownItemScreenArgs{key: $key, replicaLink: $replicaLink, category: $category, mimeType: $mimeType}';
  }
}

/// generated route for
/// [_i27.ReplicaSearchScreen]
class ReplicaSearchScreen extends _i33.PageRouteInfo<ReplicaSearchScreenArgs> {
  ReplicaSearchScreen({_i35.Key? key, required String searchQuery})
      : super(ReplicaSearchScreen.name,
            path: 'replicaSearchScreen',
            args: ReplicaSearchScreenArgs(key: key, searchQuery: searchQuery));

  static const String name = 'ReplicaSearchScreen';
}

class ReplicaSearchScreenArgs {
  const ReplicaSearchScreenArgs({this.key, required this.searchQuery});

  final _i35.Key? key;

  final String searchQuery;

  @override
  String toString() {
    return 'ReplicaSearchScreenArgs{key: $key, searchQuery: $searchQuery}';
  }
}

/// generated route for
/// [_i28.ReplicaUploadFileScreen]
class ReplicaUploadFileScreen
    extends _i33.PageRouteInfo<ReplicaUploadFileScreenArgs> {
  ReplicaUploadFileScreen({_i35.Key? key, required _i35.File fileToUpload})
      : super(ReplicaUploadFileScreen.name,
            path: 'replicaUploadFileScreen',
            args: ReplicaUploadFileScreenArgs(
                key: key, fileToUpload: fileToUpload));

  static const String name = 'ReplicaUploadFileScreen';
}

class ReplicaUploadFileScreenArgs {
  const ReplicaUploadFileScreenArgs({this.key, required this.fileToUpload});

  final _i35.Key? key;

  final _i35.File fileToUpload;

  @override
  String toString() {
    return 'ReplicaUploadFileScreenArgs{key: $key, fileToUpload: $fileToUpload}';
  }
}

/// generated route for
/// [_i29.Upgrade]
class Upgrade extends _i33.PageRouteInfo<UpgradeArgs> {
  Upgrade({_i35.Key? key})
      : super(Upgrade.name, path: 'upgrade', args: UpgradeArgs(key: key));

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
/// [_i30.Checkout]
class Checkout extends _i33.PageRouteInfo<CheckoutArgs> {
  Checkout({required String id, _i35.Key? key})
      : super(Checkout.name,
            path: 'checkout', args: CheckoutArgs(id: id, key: key));

  static const String name = 'Checkout';
}

class CheckoutArgs {
  const CheckoutArgs({required this.id, this.key});

  final String id;

  final _i35.Key? key;

  @override
  String toString() {
    return 'CheckoutArgs{id: $id, key: $key}';
  }
}

/// generated route for
/// [_i31.StripeCheckout]
class StripeCheckout extends _i33.PageRouteInfo<StripeCheckoutArgs> {
  StripeCheckout(
      {required String email,
      String? refCode,
      required String id,
      _i35.Key? key})
      : super(StripeCheckout.name,
            path: 'stripeCheckout',
            args: StripeCheckoutArgs(
                email: email, refCode: refCode, id: id, key: key));

  static const String name = 'StripeCheckout';
}

class StripeCheckoutArgs {
  const StripeCheckoutArgs(
      {required this.email, this.refCode, required this.id, this.key});

  final String email;

  final String? refCode;

  final String id;

  final _i35.Key? key;

  @override
  String toString() {
    return 'StripeCheckoutArgs{email: $email, refCode: $refCode, id: $id, key: $key}';
  }
}

/// generated route for
/// [_i32.ActivationCodeCheckout]
class ActivationCodeCheckout
    extends _i33.PageRouteInfo<ActivationCodeCheckoutArgs> {
  ActivationCodeCheckout({_i35.Key? key})
      : super(ActivationCodeCheckout.name,
            path: 'activationCodeCheckout',
            args: ActivationCodeCheckoutArgs(key: key));

  static const String name = 'ActivationCodeCheckout';
}

class ActivationCodeCheckoutArgs {
  const ActivationCodeCheckoutArgs({this.key});

  final _i35.Key? key;

  @override
  String toString() {
    return 'ActivationCodeCheckoutArgs{key: $key}';
  }
}

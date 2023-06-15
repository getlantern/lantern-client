// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i35;

import 'package:auto_route/auto_route.dart' as _i31;
import 'package:flutter/cupertino.dart' as _i33;
import 'package:lantern/account/account_management.dart' as _i13;
import 'package:lantern/account/blocked_users.dart' as _i20;
import 'package:lantern/account/chat_number_account.dart' as _i19;
import 'package:lantern/account/device_linking/approve_device.dart' as _i15;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i17;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i16;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i14;
import 'package:lantern/account/language.dart' as _i21;
import 'package:lantern/account/recovery_key.dart' as _i12;
import 'package:lantern/account/settings.dart' as _i22;
import 'package:lantern/account/support.dart' as _i18;
import 'package:lantern/common/common.dart' as _i32;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i3;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i23;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i24;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i25;
import 'package:lantern/messaging/conversation/conversation.dart' as _i30;
import 'package:lantern/messaging/introductions/introduce.dart' as _i27;
import 'package:lantern/messaging/introductions/introductions.dart' as _i26;
import 'package:lantern/messaging/messaging.dart' as _i36;
import 'package:lantern/messaging/onboarding/chat_number_messaging.dart'
    as _i29;
import 'package:lantern/messaging/onboarding/chat_number_recovery.dart' as _i28;
import 'package:lantern/replica/common.dart' as _i34;
import 'package:lantern/replica/link_handler.dart' as _i8;
import 'package:lantern/replica/ui/viewers/audio.dart' as _i4;
import 'package:lantern/replica/ui/viewers/image.dart' as _i5;
import 'package:lantern/replica/ui/viewers/misc.dart' as _i7;
import 'package:lantern/replica/ui/viewers/video.dart' as _i6;
import 'package:lantern/replica/upload/description.dart' as _i10;
import 'package:lantern/replica/upload/review.dart' as _i9;
import 'package:lantern/replica/upload/title.dart' as _i11;
import 'package:lantern/vpn/vpn_split_tunneling.dart' as _i2;

abstract class $AppRouter extends _i31.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i31.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i31.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.HomePage(key: args.key),
      );
    },
    SplitTunneling.name: (routeData) {
      final args = routeData.argsAs<SplitTunnelingArgs>(
          orElse: () => const SplitTunnelingArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i2.SplitTunneling(key: args.key),
      );
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i3.FullScreenDialog(
          widget: args.widget,
          key: args.key,
        ),
      );
    },
    ReplicaAudioViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaAudioViewerArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i4.ReplicaAudioViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaImageViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaImageViewerArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i5.ReplicaImageViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaVideoViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaVideoViewerArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i6.ReplicaVideoViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaMiscViewer.name: (routeData) {
      final args = routeData.argsAs<ReplicaMiscViewerArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i7.ReplicaMiscViewer(
          replicaApi: args.replicaApi,
          item: args.item,
          category: args.category,
        ),
      );
    },
    ReplicaLinkHandler.name: (routeData) {
      final args = routeData.argsAs<ReplicaLinkHandlerArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i8.ReplicaLinkHandler(
          key: args.key,
          replicaApi: args.replicaApi,
          replicaLink: args.replicaLink,
        ),
      );
    },
    ReplicaUploadReview.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadReviewArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i9.ReplicaUploadReview(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadDescription.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadDescriptionArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i10.ReplicaUploadDescription(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    ReplicaUploadTitle.name: (routeData) {
      final args = routeData.argsAs<ReplicaUploadTitleArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i11.ReplicaUploadTitle(
          key: args.key,
          fileToUpload: args.fileToUpload,
          fileTitle: args.fileTitle,
          fileDescription: args.fileDescription,
        ),
      );
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i12.RecoveryKey(key: args.key),
      );
    },
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i13.AccountManagement(
          key: args.key,
          isPro: args.isPro,
        ),
      );
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i14.AuthorizeDeviceViaEmailPin(key: args.key),
      );
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i15.ApproveDevice(key: args.key),
      );
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i16.AuthorizeDeviceViaEmail(key: args.key),
      );
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i17.AuthorizeDeviceForPro(key: args.key),
      );
    },
    Support.name: (routeData) {
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: const _i18.Support(),
      );
    },
    ChatNumberAccount.name: (routeData) {
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i19.ChatNumberAccount(),
      );
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i20.BlockedUsers(key: args.key),
      );
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i21.Language(key: args.key),
      );
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i22.Settings(key: args.key),
      );
    },
    AddViaChatNumber.name: (routeData) {
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i23.AddViaChatNumber(),
      );
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i24.ContactInfo(contact: args.contact),
      );
    },
    NewChat.name: (routeData) {
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i25.NewChat(),
      );
    },
    Introductions.name: (routeData) {
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i26.Introductions(),
      );
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i27.Introduce(
          singleIntro: args.singleIntro,
          contactToIntro: args.contactToIntro,
        ),
      );
    },
    ChatNumberRecovery.name: (routeData) {
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i28.ChatNumberRecovery(),
      );
    },
    ChatNumberMessaging.name: (routeData) {
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i29.ChatNumberMessaging(),
      );
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i31.AutoRoutePage<void>(
        routeData: routeData,
        child: _i30.Conversation(
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
class Home extends _i31.PageRouteInfo<HomeArgs> {
  Home({
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          Home.name,
          args: HomeArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Home';

  static const _i31.PageInfo<HomeArgs> page = _i31.PageInfo<HomeArgs>(name);
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i32.Key? key;

  @override
  String toString() {
    return 'HomeArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.SplitTunneling]
class SplitTunneling extends _i31.PageRouteInfo<SplitTunnelingArgs> {
  SplitTunneling({
    _i33.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          SplitTunneling.name,
          args: SplitTunnelingArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SplitTunneling';

  static const _i31.PageInfo<SplitTunnelingArgs> page =
      _i31.PageInfo<SplitTunnelingArgs>(name);
}

class SplitTunnelingArgs {
  const SplitTunnelingArgs({this.key});

  final _i33.Key? key;

  @override
  String toString() {
    return 'SplitTunnelingArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.FullScreenDialog]
class FullScreenDialogPage
    extends _i31.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({
    required _i32.Widget widget,
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          FullScreenDialogPage.name,
          args: FullScreenDialogPageArgs(
            widget: widget,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'FullScreenDialogPage';

  static const _i31.PageInfo<FullScreenDialogPageArgs> page =
      _i31.PageInfo<FullScreenDialogPageArgs>(name);
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({
    required this.widget,
    this.key,
  });

  final _i32.Widget widget;

  final _i32.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for
/// [_i4.ReplicaAudioViewer]
class ReplicaAudioViewer extends _i31.PageRouteInfo<ReplicaAudioViewerArgs> {
  ReplicaAudioViewer({
    required _i34.ReplicaApi replicaApi,
    required _i34.ReplicaSearchItem item,
    required _i34.SearchCategory category,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaAudioViewerArgs> page =
      _i31.PageInfo<ReplicaAudioViewerArgs>(name);
}

class ReplicaAudioViewerArgs {
  const ReplicaAudioViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i34.ReplicaApi replicaApi;

  final _i34.ReplicaSearchItem item;

  final _i34.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaAudioViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i5.ReplicaImageViewer]
class ReplicaImageViewer extends _i31.PageRouteInfo<ReplicaImageViewerArgs> {
  ReplicaImageViewer({
    required _i34.ReplicaApi replicaApi,
    required _i34.ReplicaSearchItem item,
    required _i34.SearchCategory category,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaImageViewerArgs> page =
      _i31.PageInfo<ReplicaImageViewerArgs>(name);
}

class ReplicaImageViewerArgs {
  const ReplicaImageViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i34.ReplicaApi replicaApi;

  final _i34.ReplicaSearchItem item;

  final _i34.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaImageViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i6.ReplicaVideoViewer]
class ReplicaVideoViewer extends _i31.PageRouteInfo<ReplicaVideoViewerArgs> {
  ReplicaVideoViewer({
    required _i34.ReplicaApi replicaApi,
    required _i34.ReplicaSearchItem item,
    required _i34.SearchCategory category,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaVideoViewerArgs> page =
      _i31.PageInfo<ReplicaVideoViewerArgs>(name);
}

class ReplicaVideoViewerArgs {
  const ReplicaVideoViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i34.ReplicaApi replicaApi;

  final _i34.ReplicaSearchItem item;

  final _i34.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaVideoViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i7.ReplicaMiscViewer]
class ReplicaMiscViewer extends _i31.PageRouteInfo<ReplicaMiscViewerArgs> {
  ReplicaMiscViewer({
    required _i34.ReplicaApi replicaApi,
    required _i34.ReplicaSearchItem item,
    required _i34.SearchCategory category,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaMiscViewerArgs> page =
      _i31.PageInfo<ReplicaMiscViewerArgs>(name);
}

class ReplicaMiscViewerArgs {
  const ReplicaMiscViewerArgs({
    required this.replicaApi,
    required this.item,
    required this.category,
  });

  final _i34.ReplicaApi replicaApi;

  final _i34.ReplicaSearchItem item;

  final _i34.SearchCategory category;

  @override
  String toString() {
    return 'ReplicaMiscViewerArgs{replicaApi: $replicaApi, item: $item, category: $category}';
  }
}

/// generated route for
/// [_i8.ReplicaLinkHandler]
class ReplicaLinkHandler extends _i31.PageRouteInfo<ReplicaLinkHandlerArgs> {
  ReplicaLinkHandler({
    _i32.Key? key,
    required _i34.ReplicaApi replicaApi,
    required _i34.ReplicaLink replicaLink,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaLinkHandlerArgs> page =
      _i31.PageInfo<ReplicaLinkHandlerArgs>(name);
}

class ReplicaLinkHandlerArgs {
  const ReplicaLinkHandlerArgs({
    this.key,
    required this.replicaApi,
    required this.replicaLink,
  });

  final _i32.Key? key;

  final _i34.ReplicaApi replicaApi;

  final _i34.ReplicaLink replicaLink;

  @override
  String toString() {
    return 'ReplicaLinkHandlerArgs{key: $key, replicaApi: $replicaApi, replicaLink: $replicaLink}';
  }
}

/// generated route for
/// [_i9.ReplicaUploadReview]
class ReplicaUploadReview extends _i31.PageRouteInfo<ReplicaUploadReviewArgs> {
  ReplicaUploadReview({
    _i32.Key? key,
    required _i35.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaUploadReviewArgs> page =
      _i31.PageInfo<ReplicaUploadReviewArgs>(name);
}

class ReplicaUploadReviewArgs {
  const ReplicaUploadReviewArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i32.Key? key;

  final _i35.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadReviewArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i10.ReplicaUploadDescription]
class ReplicaUploadDescription
    extends _i31.PageRouteInfo<ReplicaUploadDescriptionArgs> {
  ReplicaUploadDescription({
    _i32.Key? key,
    required _i35.File fileToUpload,
    required String fileTitle,
    String? fileDescription,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaUploadDescriptionArgs> page =
      _i31.PageInfo<ReplicaUploadDescriptionArgs>(name);
}

class ReplicaUploadDescriptionArgs {
  const ReplicaUploadDescriptionArgs({
    this.key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  final _i32.Key? key;

  final _i35.File fileToUpload;

  final String fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadDescriptionArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i11.ReplicaUploadTitle]
class ReplicaUploadTitle extends _i31.PageRouteInfo<ReplicaUploadTitleArgs> {
  ReplicaUploadTitle({
    _i32.Key? key,
    required _i35.File fileToUpload,
    String? fileTitle,
    String? fileDescription,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ReplicaUploadTitleArgs> page =
      _i31.PageInfo<ReplicaUploadTitleArgs>(name);
}

class ReplicaUploadTitleArgs {
  const ReplicaUploadTitleArgs({
    this.key,
    required this.fileToUpload,
    this.fileTitle,
    this.fileDescription,
  });

  final _i32.Key? key;

  final _i35.File fileToUpload;

  final String? fileTitle;

  final String? fileDescription;

  @override
  String toString() {
    return 'ReplicaUploadTitleArgs{key: $key, fileToUpload: $fileToUpload, fileTitle: $fileTitle, fileDescription: $fileDescription}';
  }
}

/// generated route for
/// [_i12.RecoveryKey]
class RecoveryKey extends _i31.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({
    _i36.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          RecoveryKey.name,
          args: RecoveryKeyArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RecoveryKey';

  static const _i31.PageInfo<RecoveryKeyArgs> page =
      _i31.PageInfo<RecoveryKeyArgs>(name);
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i36.Key? key;

  @override
  String toString() {
    return 'RecoveryKeyArgs{key: $key}';
  }
}

/// generated route for
/// [_i13.AccountManagement]
class AccountManagement extends _i31.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({
    _i36.Key? key,
    required bool isPro,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          AccountManagement.name,
          args: AccountManagementArgs(
            key: key,
            isPro: isPro,
          ),
          initialChildren: children,
        );

  static const String name = 'AccountManagement';

  static const _i31.PageInfo<AccountManagementArgs> page =
      _i31.PageInfo<AccountManagementArgs>(name);
}

class AccountManagementArgs {
  const AccountManagementArgs({
    this.key,
    required this.isPro,
  });

  final _i36.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for
/// [_i14.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i31.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmailPin.name,
          args: AuthorizeDeviceEmailPinArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmailPin';

  static const _i31.PageInfo<AuthorizeDeviceEmailPinArgs> page =
      _i31.PageInfo<AuthorizeDeviceEmailPinArgs>(name);
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i32.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailPinArgs{key: $key}';
  }
}

/// generated route for
/// [_i15.ApproveDevice]
class ApproveDevice extends _i31.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          ApproveDevice.name,
          args: ApproveDeviceArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ApproveDevice';

  static const _i31.PageInfo<ApproveDeviceArgs> page =
      _i31.PageInfo<ApproveDeviceArgs>(name);
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i32.Key? key;

  @override
  String toString() {
    return 'ApproveDeviceArgs{key: $key}';
  }
}

/// generated route for
/// [_i16.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i31.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          AuthorizeDeviceEmail.name,
          args: AuthorizeDeviceEmailArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizeDeviceEmail';

  static const _i31.PageInfo<AuthorizeDeviceEmailArgs> page =
      _i31.PageInfo<AuthorizeDeviceEmailArgs>(name);
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i32.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailArgs{key: $key}';
  }
}

/// generated route for
/// [_i17.AuthorizeDeviceForPro]
class AuthorizePro extends _i31.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          AuthorizePro.name,
          args: AuthorizeProArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthorizePro';

  static const _i31.PageInfo<AuthorizeProArgs> page =
      _i31.PageInfo<AuthorizeProArgs>(name);
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i32.Key? key;

  @override
  String toString() {
    return 'AuthorizeProArgs{key: $key}';
  }
}

/// generated route for
/// [_i18.Support]
class Support extends _i31.PageRouteInfo<void> {
  const Support({List<_i31.PageRouteInfo>? children})
      : super(
          Support.name,
          initialChildren: children,
        );

  static const String name = 'Support';

  static const _i31.PageInfo<void> page = _i31.PageInfo<void>(name);
}

/// generated route for
/// [_i19.ChatNumberAccount]
class ChatNumberAccount extends _i31.PageRouteInfo<void> {
  const ChatNumberAccount({List<_i31.PageRouteInfo>? children})
      : super(
          ChatNumberAccount.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberAccount';

  static const _i31.PageInfo<void> page = _i31.PageInfo<void>(name);
}

/// generated route for
/// [_i20.BlockedUsers]
class BlockedUsers extends _i31.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({
    _i36.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          BlockedUsers.name,
          args: BlockedUsersArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'BlockedUsers';

  static const _i31.PageInfo<BlockedUsersArgs> page =
      _i31.PageInfo<BlockedUsersArgs>(name);
}

class BlockedUsersArgs {
  const BlockedUsersArgs({this.key});

  final _i36.Key? key;

  @override
  String toString() {
    return 'BlockedUsersArgs{key: $key}';
  }
}

/// generated route for
/// [_i21.Language]
class Language extends _i31.PageRouteInfo<LanguageArgs> {
  Language({
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          Language.name,
          args: LanguageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Language';

  static const _i31.PageInfo<LanguageArgs> page =
      _i31.PageInfo<LanguageArgs>(name);
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i32.Key? key;

  @override
  String toString() {
    return 'LanguageArgs{key: $key}';
  }
}

/// generated route for
/// [_i22.Settings]
class Settings extends _i31.PageRouteInfo<SettingsArgs> {
  Settings({
    _i32.Key? key,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          Settings.name,
          args: SettingsArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Settings';

  static const _i31.PageInfo<SettingsArgs> page =
      _i31.PageInfo<SettingsArgs>(name);
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i32.Key? key;

  @override
  String toString() {
    return 'SettingsArgs{key: $key}';
  }
}

/// generated route for
/// [_i23.AddViaChatNumber]
class AddViaChatNumber extends _i31.PageRouteInfo<void> {
  const AddViaChatNumber({List<_i31.PageRouteInfo>? children})
      : super(
          AddViaChatNumber.name,
          initialChildren: children,
        );

  static const String name = 'AddViaChatNumber';

  static const _i31.PageInfo<void> page = _i31.PageInfo<void>(name);
}

/// generated route for
/// [_i24.ContactInfo]
class ContactInfo extends _i31.PageRouteInfo<ContactInfoArgs> {
  ContactInfo({
    required _i36.Contact contact,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          ContactInfo.name,
          args: ContactInfoArgs(contact: contact),
          initialChildren: children,
        );

  static const String name = 'ContactInfo';

  static const _i31.PageInfo<ContactInfoArgs> page =
      _i31.PageInfo<ContactInfoArgs>(name);
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.contact});

  final _i36.Contact contact;

  @override
  String toString() {
    return 'ContactInfoArgs{contact: $contact}';
  }
}

/// generated route for
/// [_i25.NewChat]
class NewChat extends _i31.PageRouteInfo<void> {
  const NewChat({List<_i31.PageRouteInfo>? children})
      : super(
          NewChat.name,
          initialChildren: children,
        );

  static const String name = 'NewChat';

  static const _i31.PageInfo<void> page = _i31.PageInfo<void>(name);
}

/// generated route for
/// [_i26.Introductions]
class Introductions extends _i31.PageRouteInfo<void> {
  const Introductions({List<_i31.PageRouteInfo>? children})
      : super(
          Introductions.name,
          initialChildren: children,
        );

  static const String name = 'Introductions';

  static const _i31.PageInfo<void> page = _i31.PageInfo<void>(name);
}

/// generated route for
/// [_i27.Introduce]
class Introduce extends _i31.PageRouteInfo<IntroduceArgs> {
  Introduce({
    required bool singleIntro,
    _i36.Contact? contactToIntro,
    List<_i31.PageRouteInfo>? children,
  }) : super(
          Introduce.name,
          args: IntroduceArgs(
            singleIntro: singleIntro,
            contactToIntro: contactToIntro,
          ),
          initialChildren: children,
        );

  static const String name = 'Introduce';

  static const _i31.PageInfo<IntroduceArgs> page =
      _i31.PageInfo<IntroduceArgs>(name);
}

class IntroduceArgs {
  const IntroduceArgs({
    required this.singleIntro,
    this.contactToIntro,
  });

  final bool singleIntro;

  final _i36.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for
/// [_i28.ChatNumberRecovery]
class ChatNumberRecovery extends _i31.PageRouteInfo<void> {
  const ChatNumberRecovery({List<_i31.PageRouteInfo>? children})
      : super(
          ChatNumberRecovery.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberRecovery';

  static const _i31.PageInfo<void> page = _i31.PageInfo<void>(name);
}

/// generated route for
/// [_i29.ChatNumberMessaging]
class ChatNumberMessaging extends _i31.PageRouteInfo<void> {
  const ChatNumberMessaging({List<_i31.PageRouteInfo>? children})
      : super(
          ChatNumberMessaging.name,
          initialChildren: children,
        );

  static const String name = 'ChatNumberMessaging';

  static const _i31.PageInfo<void> page = _i31.PageInfo<void>(name);
}

/// generated route for
/// [_i30.Conversation]
class Conversation extends _i31.PageRouteInfo<ConversationArgs> {
  Conversation({
    required _i36.ContactId contactId,
    int? initialScrollIndex,
    bool showContactEditingDialog = false,
    List<_i31.PageRouteInfo>? children,
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

  static const _i31.PageInfo<ConversationArgs> page =
      _i31.PageInfo<ConversationArgs>(name);
}

class ConversationArgs {
  const ConversationArgs({
    required this.contactId,
    this.initialScrollIndex,
    this.showContactEditingDialog = false,
  });

  final _i36.ContactId contactId;

  final int? initialScrollIndex;

  final bool showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

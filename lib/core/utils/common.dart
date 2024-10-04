import 'dart:io';

import 'package:lantern/features/replica/common.dart';
import 'package:logger/logger.dart';

import 'common.dart';

export 'dart:async';
export 'dart:convert';
export 'dart:io';
export 'dart:math';
export 'dart:typed_data';
export  'package:lantern/core/app/app_webview.dart';
export 'package:auto_route/auto_route.dart';
export 'package:back_button_interceptor/back_button_interceptor.dart';
export 'package:dotted_border/dotted_border.dart';
export 'package:flag/flag.dart';
export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
// export 'package:i18n_extension/i18n_widget.dart';
// export 'package:flutter_switch/flutter_switch.dart';
export 'package:i18n_extension/src/i18n_widget.dart';
export 'package:lantern/core/router/router.gr.dart';

// Services
export 'package:lantern/core/service/injection_container.dart';
export 'package:lantern/core/extension/event_extension.dart';
export 'package:lantern/core/service/event_manager.dart';
export 'package:lantern/core/localization/i18n.dart';
export 'package:lantern/features/vpn/protos_shared/vpn.pb.dart';
export 'package:lantern/features/vpn/vpn_model.dart';
export 'package:loader_overlay/loader_overlay.dart';
export 'package:provider/provider.dart';
export 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
export 'package:stop_watch_timer/stop_watch_timer.dart';


export 'add_nonbreaking_spaces.dart';
export '../app/app_keys.dart';
export '../app/app_const.dart';
export '../app/app_enums.dart';
export '../app/app_extension.dart';
export '../extension/error_extension.dart';
export '../app/app_keys.dart';
export '../app/app_methods.dart';
export '../app/app_secret.dart';
export 'disable_back_button.dart';
export '../extension/iterable_extension.dart';
export '../subscribers/list_subscriber.dart';
export 'lru_cache.dart';
export '../native/model.dart';
export '../native/model_event_channel.dart';
export 'once.dart';
export '../../features/home/session_model.dart';
export '../subscribers/single_value_subscriber.dart';
export '../app/app_buttons.dart';
export '../../common/ui/audio.dart';
export '../../common/ui/base_screen.dart';
export '../../common/ui/basic_memory_image.dart';
export '../theme/colors.dart';
export '../../common/ui/continue_arrow.dart';
export '../../common/ui/copy_text.dart';
export '../../common/ui/countdown_min_sec.dart';
export '../../common/ui/countdown_stopwatch.dart';
// custom components
export '../../common/ui/custom/asset_image.dart';
export '../../common/ui/custom/badge.dart';
export '../../common/ui/custom/dialog.dart';
export '../../common/ui/custom/divider.dart';
export '../../common/ui/custom/fullscreen_image_viewer.dart';
export '../../common/ui/custom/fullscreen_video_viewer.dart';
export '../../common/ui/custom/fullscreen_viewer.dart';
export '../../common/ui/custom/ink_well.dart';
export '../../common/ui/custom/list_item_factory.dart';
export '../../common/ui/custom/logo_with_text.dart';
export '../../common/ui/custom/retry_widget.dart';
export '../../common/ui/custom/rounded_rectangle_border.dart';
export '../../common/ui/custom/text.dart';
export '../../common/ui/custom/text_field.dart';
export '../../common/ui/dimens.dart';
export '../../common/ui/focused_menu.dart';
export '../../common/ui/full_screen_dialog.dart';
export '../../common/ui/humanize_duration.dart';
export '../../common/ui/humanize_past_future.dart';
export '../../common/ui/humanize_seconds.dart';
export '../../common/ui/humanized_date.dart';
export '../../common/ui/image_paths.dart';
export '../../common/ui/info_text_box.dart';
export '../../common/ui/labeled_divider.dart';
export '../../common/ui/list_section_header.dart';
export '../../common/ui/now_builder.dart';
export '../../common/ui/path_building.dart';
export '../../common/ui/pin_field.dart';
export '../../common/ui/pinned_button_layout.dart';
export '../../common/ui/play_button.dart';
export '../../common/ui/pulse_animation.dart';
export '../../common/ui/round_button.dart';
export '../../common/ui/search_field.dart';
export '../../common/ui/show_bottom_modal.dart';
export '../../common/ui/show_snackbar.dart';
export '../../common/ui/text_highlighter.dart';
export '../theme/text_styles.dart';
export '../../common/ui/transitions.dart';
export '../../common/ui/custom/logo_with_text.dart';

// custom components
export '../../common/ui/custom/asset_image.dart';
export '../../common/ui/custom/badge.dart';
export '../../common/ui/custom/dialog.dart';
export '../../common/ui/custom/divider.dart';
export '../../common/ui/custom/ink_well.dart';
export '../../common/ui/custom/list_item_factory.dart';
export '../../common/ui/custom/rounded_rectangle_border.dart';
export '../../common/ui/custom/text.dart';
export '../../common/ui/custom/text_field.dart';
export '../../common/ui/custom/fullscreen_video_viewer.dart';
export '../../common/ui/custom/fullscreen_image_viewer.dart';
export '../../common/ui/custom/fullscreen_viewer.dart';

export '../../common/ui/custom/heading_text.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
  filter: ProductionFilter(),
  output: ConsoleOutput(),
);

// We need to check platform using flutter foundation defaultTargetPlatform
// so while testing we can easily override the platform
// Als this recommended way to check platform from Flutter Team
bool isMobile() {
  if (kDebugMode) {
  return (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS);
  }
  return Platform.isAndroid || Platform.isIOS;
}

bool isDesktop() {
  if (kDebugMode) {
    return (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.windows);
  }
  return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}

final mainLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 10,
      colors: true,
      printEmojis: true,
      printTime: true,
    ), filter: DevelopmentFilter(), level: Level.debug);

import 'dart:io';

import 'package:lantern/replica/common.dart';

export 'dart:async';
export 'dart:convert';
export 'dart:io';
export 'dart:math';
export 'dart:typed_data';

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
export 'package:flutter_switch/flutter_switch.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/core/router/router.gr.dart';
export 'package:lantern/event_extension.dart';
export 'package:lantern/event_manager.dart';
export 'package:lantern/i18n/i18n.dart';
export 'package:lantern/vpn/protos_shared/vpn.pb.dart';
export 'package:lantern/vpn/vpn_model.dart';
export 'package:loader_overlay/loader_overlay.dart';
export 'package:provider/provider.dart';
export 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
export 'package:stop_watch_timer/stop_watch_timer.dart';

export 'add_nonbreaking_spaces.dart';
export 'app_keys.dart';
export 'disable_back_button.dart';
export 'iterable_extension.dart';
export 'list_subscriber.dart';
export 'lru_cache.dart';
export 'model.dart';
export 'model_event_channel.dart';
export 'once.dart';
export 'session_model.dart';
export 'single_value_subscriber.dart';
export 'ui/audio.dart';
export 'ui/base_screen.dart';
export 'ui/basic_memory_image.dart';
export 'ui/button.dart';
export 'ui/colors.dart';
export 'ui/continue_arrow.dart';
export 'ui/copy_text.dart';
export 'ui/countdown_min_sec.dart';
export 'ui/countdown_stopwatch.dart';

// custom components
export 'ui/custom/asset_image.dart';
export 'ui/custom/badge.dart';
export 'ui/custom/dialog.dart';
export 'ui/custom/divider.dart';
export 'ui/custom/fullscreen_image_viewer.dart';
export 'ui/custom/fullscreen_video_viewer.dart';
export 'ui/custom/fullscreen_viewer.dart';
export 'ui/custom/ink_well.dart';
export 'ui/custom/list_item_factory.dart';
export 'ui/custom/rounded_rectangle_border.dart';
export 'ui/custom/text.dart';
export 'ui/custom/text_field.dart';
export 'ui/custom/retry_widget.dart';
export 'ui/dimens.dart';
export 'ui/focused_menu.dart';
export 'ui/full_screen_dialog.dart';
export 'ui/humanize_duration.dart';
export 'ui/humanize_past_future.dart';
export 'ui/humanize_seconds.dart';
export 'ui/humanized_date.dart';
export 'ui/image_paths.dart';
export 'ui/info_text_box.dart';
export 'ui/labeled_divider.dart';
export 'ui/list_section_header.dart';
export 'ui/now_builder.dart';
export 'ui/path_building.dart';
export 'ui/pin_field.dart';
export 'ui/pinned_button_layout.dart';
export 'ui/play_button.dart';
export 'ui/pulse_animation.dart';
export 'ui/round_button.dart';
export 'ui/search_field.dart';
export 'ui/show_bottom_modal.dart';
export 'ui/show_snackbar.dart';

export 'ui/text_highlighter.dart';
export 'ui/text_styles.dart';
export 'ui/transitions.dart';
export 'app_secret.dart';

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

bool isMobile() {
  return Platform.isAndroid || Platform.isIOS;
}

bool isDesktop() {
  return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}

import 'package:lantern/common/common.dart';

class ListItemFactory extends StatelessWidget {
  late final String? header;
  final dynamic leading;
  final dynamic content;
  late final String? subtitle;
  final List<Widget>? trailingArray;
  final void Function()? onTap;
  late final double? height;
  late final double? endPadding;
  late final bool? showDivider;
  late final SizedBox? focusedMenu;
  late final bool? hasCopiedRecoveryKey;

  late final _ItemTypology renderAs;

  ListItemFactory.settingsItem({
    Key? key,
    this.header,
    this.leading,
    this.content,
    this.onTap,
    this.trailingArray,
  }) : super(key: key) {
    renderAs = _ItemTypology.isSettingsItem;
  }

  ListItemFactory.bottomItem({
    Key? key,
    this.leading,
    this.content,
    this.trailingArray,
    this.onTap,
  }) : super(key: key) {
    renderAs = _ItemTypology.isBottomItem;
  }

  ListItemFactory.focusMenuItem({
    Key? key,
    this.leading,
    this.content,
    this.onTap,
    this.trailingArray,
  }) : super(key: key) {
    renderAs = _ItemTypology.isFocusMenuItem;
  }

  // contacts, messages, search results
  ListItemFactory.messagingItem({
    Key? key,
    this.header,
    this.leading,
    this.content,
    this.onTap,
    this.trailingArray,
    this.subtitle,
    this.height,
    this.endPadding,
    this.showDivider = true,
    this.focusedMenu,
    this.hasCopiedRecoveryKey,
  }) : super(key: key) {
    renderAs = _ItemTypology.isMessagingItem;
  }

  @override
  Widget build(BuildContext context) {
    switch (renderAs) {
      // * SETTINGS ITEM
      // Renders in Accounts and Settings
      case _ItemTypology.isSettingsItem:
        {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ListSectionHeader(header!),
              buildBase(
                leading: leading,
                content: content,
                trailingArray: trailingArray,
                onTap: onTap,
                showDivider: true,
                disableSplash: true,
              ),
            ],
          );
        }
      // * BOTTOM MODAL ITEM
      // Renders in bottom modal lists
      case _ItemTypology.isBottomItem:
        {
          return Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            child: buildBase(
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: leading,
              ),
              content: content,
              trailingArray: trailingArray,
              onTap: onTap,
              showDivider: true,
              height: 56,
            ),
          );
        }
      // * FOCUS ITEM
      // Renders in the FocusableMenu list on long press of specific items
      case _ItemTypology.isFocusMenuItem:
        {
          return buildBase(
            leading: leading,
            content: content,
            trailingArray: [],
            onTap: onTap,
            height: 48,
            showDivider: false,
          );
        }
      // * MESSAGING ITEM
      // Anything that contains an avatar, title, subtitle, and trailing actions
      case _ItemTypology.isMessagingItem:
        {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ListSectionHeader(header!),
              FocusedMenuHolder(
                menu: focusedMenu ?? const SizedBox(),
                onOpen: () {},
                menuWidth: MediaQuery.of(context).size.width * 0.8,
                builder: (menuOpen) => Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: buildBase(
                    height: height,
                    leading: leading,
                    content: content,
                    trailingArray: trailingArray,
                    showDivider: showDivider! && !menuOpen,
                    onTap: onTap,
                    enableHighlighting: true,
                    subtitle: subtitle,
                  ),
                ),
              ),
            ],
          );
        }
      default:
        {
          return const SizedBox();
        }
    }
  }

  Widget buildBase({
    dynamic leading,
    required dynamic content,
    required bool showDivider,
    double? height,
    Function()? onTap,
    List<Widget>? trailingArray,
    double? endPadding,
    bool? enableHighlighting,
    bool? disableSplash,
    String? subtitle,
  }) =>
      Material(
          color: transparent,
          child: CInkWell(
            disableSplash: disableSplash ?? false,
            onTap: onTap ?? () {},
            child: Container(
              height: height ?? 72,
              decoration: showDivider
                  ? BoxDecoration(
                      border:
                          Border(bottom: BorderSide(width: 1, color: grey3)),
                    )
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leading != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 4.0, end: 16.0),
                      child: buildLeading(leading),
                    ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      child: buildContent(
                          content: content,
                          subtitle: subtitle,
                          enableHighlighting: enableHighlighting),
                    ),
                  ),
                  if (trailingArray != null && trailingArray.isNotEmpty)
                    buildTrailing(
                      trailingArray: trailingArray,
                      endPadding: endPadding,
                    ),
                ],
              ),
            ),
          ));

  Widget? buildLeading(dynamic leading) {
    if (leading == null) {
      return null;
    }

    if (leading is Widget) {
      return leading;
    }

    if (leading is String) {
      return CAssetImage(
        path: leading,
        size: 24,
      );
    }

    assert(false, 'unsupported leading type ${leading.runtimeType}');
    return null;
  }

  Widget buildContent({
    required dynamic content,
    String? subtitle,
    bool? enableHighlighting = false,
  }) {
    // we are passing something custom, return as widget
    if (content is Widget) {
      return content;
    }

    // we are passing a String, look for subtitle and return as Column
    if (content is String) {
      var title = content;
      var firstLineStyle = tsSubtitle1;
      if (subtitle == null) {
        firstLineStyle = firstLineStyle.short;
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          enableHighlighting != null && enableHighlighting
              ? TextHighlighter(text: title, style: firstLineStyle)
              : CText(title.toString(), maxLines: 1, style: firstLineStyle),
          if (subtitle != null)
            enableHighlighting != null && enableHighlighting
                ? TextHighlighter(text: subtitle, style: tsBody2)
                : CText(subtitle,
                    maxLines: 1, style: tsBody2.copiedWith(color: grey5)),
        ],
      );
    }

    assert(false, 'unsupported content type ${content.runtimeType}');
    return const SizedBox();
  }

  Widget buildTrailing({
    required List<Widget> trailingArray,
    double? endPadding,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.only(end: endPadding ?? 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...trailingArray,
        ],
      ),
    );
  }
}

enum _ItemTypology {
  isSettingsItem,
  isBottomItem,
  isFocusMenuItem,
  isMessagingItem,
}

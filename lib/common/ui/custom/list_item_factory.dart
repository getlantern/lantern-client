import 'package:lantern/common/common.dart';

class ListItemFactory extends StatelessWidget {
  final dynamic leading;
  final dynamic content;
  final String? subtitle;
  final String? header;
  final List<Widget>? trailingArray;
  final double? height;
  final double? endPadding;
  final bool? showDivider;
  final void Function()? onTap;
  final SizedBox? focusedMenu;
  final bool? hasCopiedRecoveryKey;

  late final _Typology typeToRender;

  ListItemFactory.isSettingsItem({
    Key? key,
    this.leading,
    this.content,
    this.onTap,
    this.trailingArray,
    this.header,
    this.subtitle,
    this.height,
    this.endPadding,
    this.showDivider,
    this.focusedMenu,
    this.hasCopiedRecoveryKey,
  }) : super(key: key) {
    typeToRender = _Typology.isSettingsItem;
  }

  ListItemFactory.isBottomItem({
    Key? key,
    this.leading,
    this.content,
    this.onTap,
    this.trailingArray,
    this.header,
    this.subtitle,
    this.height,
    this.endPadding,
    this.showDivider,
    this.focusedMenu,
    this.hasCopiedRecoveryKey,
  }) : super(key: key) {
    typeToRender = _Typology.isBottomItem;
  }

  ListItemFactory.isFocusMenuItem({
    Key? key,
    this.leading,
    this.content,
    this.onTap,
    this.trailingArray,
    this.header,
    this.subtitle,
    this.height,
    this.endPadding,
    this.showDivider,
    this.focusedMenu,
    this.hasCopiedRecoveryKey,
  }) : super(key: key) {
    typeToRender = _Typology.isFocusMenuItem;
  }

  // contacts, messages, search results
  ListItemFactory.isMessagingItem({
    Key? key,
    this.leading,
    this.content,
    this.onTap,
    this.trailingArray,
    this.header,
    this.subtitle,
    this.height,
    this.endPadding,
    this.showDivider = true,
    this.focusedMenu,
    this.hasCopiedRecoveryKey,
  }) : super(key: key) {
    typeToRender = _Typology.isMessagingItem;
  }

  @override
  Widget build(BuildContext context) {
    switch (typeToRender) {
      // * SETTINGS ITEM
      case _Typology.isSettingsItem:
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
      case _Typology.isBottomItem:
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
                showDivider: true,
                height: 56,
                onTap: onTap,
                content: content,
                trailingArray: [
                  mirrorLTR(
                    context: context,
                    child: const CAssetImage(
                      path: ImagePaths.keyboard_arrow_right,
                    ),
                  )
                ]),
          );
        }
      // * FOCUS ITEM
      case _Typology.isFocusMenuItem:
        {
          return buildBase(
              leading: leading,
              showDivider: false,
              height: 48,
              onTap: onTap,
              content: content,
              trailingArray: []);
        }
      // * MESSAGING ITEM
      case _Typology.isMessagingItem:
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
                  ),
                ),
              ),
            ],
          );
        }
      default:
        {
          return Container();
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
    String? subTitle,
    bool? enableHighlighting = false,
  }) {
    // we are passing something custom, return as widget
    if (content is Widget) {
      return content;
    }

    // we are passing a String, look for subtitle and return as Column
    if (content is String) {
      var title = content;
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          enableHighlighting != null && enableHighlighting
              ? TextHighlighter(text: title, style: tsSubtitle1)
              : CText(title.toString(), maxLines: 1, style: tsSubtitle1Short),
          if (subtitle != null)
            enableHighlighting != null && enableHighlighting
                ? TextHighlighter(text: subtitle!, style: tsBody2)
                : CText(subtitle!,
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

enum _Typology {
  isSettingsItem,
  isBottomItem,
  isFocusMenuItem,
  isMessagingItem,
}

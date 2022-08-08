import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/ui/utils.dart';

class ListItemFactory extends StatelessWidget {
  final Widget Function(BuildContext, ListItemFactory) builder;

  ListItemFactory(this.builder);

  ListItemFactory.uploadEditItem({
    Widget? leading,
    required Widget content,
    List<Widget>? trailingArray,
    double height = 90.0,
  }) : this((BuildContext context, ListItemFactory factory) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              factory.buildBase(
                leading: leading,
                content: content,
                trailingArray: trailingArray,
                showDivider: true,
                height: height,
              ),
            ],
          );
        });

  ListItemFactory.replicaItem({
    Widget? leading,
    required Widget content,
    required void Function() onTap,
    required ReplicaApi api,
    required ReplicaLink link,
    double height = 90.0,
  }) : this((BuildContext context, ListItemFactory factory) {
          return FocusedMenuHolder(
            menu: renderReplicaLongPressMenuItem(context, api, link),
            menuWidth: MediaQuery.of(context).size.width * 0.8,
            builder: (menuOpen) {
              return Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                child: factory.buildBase(
                  leading: leading,
                  content: content,
                  onTap: onTap,
                  height: height,
                  showDivider: !menuOpen,
                ),
              );
            },
          );
        });

  ListItemFactory.settingsItem({
    String? header,
    String? icon,
    dynamic content,
    void Function()? onTap,
    List<Widget>? trailingArray,
  }) : this((BuildContext context, ListItemFactory factory) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ListSectionHeader(header),
              factory.buildBase(
                leading: icon,
                content: content,
                trailingArray: trailingArray,
                onTap: onTap,
                showDivider: true,
                disableSplash: true,
              ),
            ],
          );
        });

  ListItemFactory.bottomItem({
    required String icon,
    dynamic content,
    List<Widget>? trailingArray,
    void Function()? onTap,
    double? height = 56,
  }) : this((BuildContext context, ListItemFactory factory) {
          return Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            child: factory.buildBase(
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: CAssetImage(path: icon, color: black),
              ),
              content: content,
              trailingArray: trailingArray,
              onTap: onTap,
              showDivider: true,
              height: height,
            ),
          );
        });

  ListItemFactory.focusMenuItem({
    required String icon,
    dynamic content,
    void Function()? onTap,
    List<Widget>? trailingArray,
  }) : this((BuildContext context, ListItemFactory factory) {
          return factory.buildBase(
            leading: icon,
            content: content,
            trailingArray: [],
            onTap: onTap,
            height: 48,
            showDivider: false,
          );
        });

  // contacts, messages, search results
  ListItemFactory.messagingItem({
    dynamic header,
    dynamic leading,
    dynamic content,
    void Function()? onTap,
    List<Widget>? trailingArray,
    String? subtitle,
    double? height,
    double? endPadding,
    bool showDivider = true,
    SizedBox? focusedMenu,
    bool? hasCopiedRecoveryKey,
    Color? customBg,
    bool? disableSplash = false,
    bool enableHighlighting = false,
  }) : this((BuildContext context, ListItemFactory factory) {
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
                    color: customBg ?? white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: factory.buildBase(
                    height: height,
                    leading: leading,
                    content: content,
                    trailingArray: trailingArray,
                    showDivider: showDivider && !menuOpen,
                    onTap: onTap,
                    enableHighlighting: enableHighlighting,
                    subtitle: subtitle,
                    disableSplash: disableSplash,
                  ),
                ),
              ),
            ],
          );
        });

  @override
  Widget build(BuildContext context) {
    return builder(context, this);
  }

  Widget buildBase({
    dynamic leading,
    required dynamic content,
    required bool showDivider,
    double? height,
    Function()? onTap,
    List<Widget>? trailingArray,
    double? endPadding,
    bool enableHighlighting = false,
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
                    border: Border(bottom: BorderSide(width: 1, color: grey3)),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 4.0,
                      end: 16.0,
                    ),
                    child: buildLeading(leading),
                  ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: buildContent(
                      content: content,
                      subtitle: subtitle,
                      enableHighlighting: enableHighlighting,
                    ),
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
        ),
      );

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
        color: black,
      );
    }

    assert(false, 'unsupported leading type ${leading.runtimeType}');
    return null;
  }

  Widget buildContent({
    required dynamic content,
    String? subtitle,
    bool enableHighlighting = false,
  }) {
    // we are passing something custom, return as widget
    if (content is Widget) {
      return content;
    }

    // we are passing a String, look for subtitle and return as Column
    if (content is String) {
      final title = content;
      final firstLineStyle = tsSubtitle1.short;
      final secondLineStyle = tsBody1.copiedWith(color: grey5).short;
      return SizedBox(
        height: 39,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            enableHighlighting
                ? TextHighlighter(text: title, style: firstLineStyle)
                : CText(title.toString(), maxLines: 1, style: firstLineStyle),
            if (subtitle != null && subtitle.isNotEmpty)
              enableHighlighting
                  ? TextHighlighter(text: subtitle, style: secondLineStyle)
                  : CText(subtitle, maxLines: 1, style: secondLineStyle),
          ],
        ),
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

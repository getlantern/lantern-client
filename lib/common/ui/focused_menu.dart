import 'dart:ui';
import 'package:flutter/material.dart';

/// Forked version of https://github.com/retroportalstudio/focused_menu that
/// always displays the focused child at the top of the page
class FocusedMenuItem {
  Color? backgroundColor;
  Widget title;
  Icon? trailingIcon;
  Function onPressed;

  FocusedMenuItem(
      {this.backgroundColor,
      required this.title,
      this.trailingIcon,
      required this.onPressed});
}

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double menuItemExtent;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final bool? animateMenuItems;
  final BoxDecoration? menuBoxDecoration;
  final Function onPressed;
  final Duration? duration;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final double menuOffset;
  final double paddingBottom;

  /// Open with tap insted of long press.
  final bool openWithTap;

  const FocusedMenuHolder(
      {Key? key,
      required this.child,
      required this.onPressed,
      required this.menuItems,
      this.duration,
      this.menuBoxDecoration,
      this.menuItemExtent = 50.0,
      this.animateMenuItems,
      this.blurSize,
      this.blurBackgroundColor,
      this.menuWidth,
      this.menuOffset = 0,
      this.paddingBottom = 0,
      this.openWithTap = false})
      : super(key: key);

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  final containerKey = GlobalKey();
  var childOffset = const Offset(0, 0);
  Size? childSize;

  void updateChildMetrics() {
    var renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      childOffset = offset;
      childSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: containerKey,
        onTap: () async {
          widget.onPressed();
          if (widget.openWithTap) {
            await openMenu(context);
          }
        },
        onLongPress: () async {
          if (!widget.openWithTap) {
            await openMenu(context);
          }
        },
        child: widget.child);
  }

  Future openMenu(BuildContext context) async {
    updateChildMetrics();
    await Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration:
                widget.duration ?? const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) {
              animation = Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(
                  opacity: animation,
                  child: FocusedMenuDetails(
                    itemExtent: widget.menuItemExtent,
                    menuBoxDecoration: widget.menuBoxDecoration,
                    childOffset: childOffset,
                    childSize: childSize,
                    menuItems: widget.menuItems,
                    blurSize: widget.blurSize,
                    menuWidth: widget.menuWidth,
                    blurBackgroundColor: widget.blurBackgroundColor,
                    animateMenu: widget.animateMenuItems ?? true,
                    menuOffset: widget.menuOffset,
                    paddingBottom: widget.paddingBottom,
                    child: widget.child,
                  ));
            },
            fullscreenDialog: true,
            opaque: false));
  }
}

class FocusedMenuDetails extends StatelessWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final double itemExtent;
  final Size? childSize;
  final Widget child;
  final bool animateMenu;
  final double? blurSize;
  final double? menuWidth;
  final Color? blurBackgroundColor;
  final double menuOffset;
  final double paddingBottom;

  const FocusedMenuDetails(
      {Key? key,
      required this.menuItems,
      required this.child,
      required this.childOffset,
      required this.childSize,
      required this.menuBoxDecoration,
      required this.itemExtent,
      required this.animateMenu,
      required this.blurSize,
      required this.blurBackgroundColor,
      required this.menuWidth,
      required this.menuOffset,
      required this.paddingBottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var size = mediaQuery.size;

    final maxMenuWidth = menuWidth ?? (size.width * 0.70);
    final menuX = (childOffset.dx + maxMenuWidth) < size.width
        ? childOffset.dx
        : (childOffset.dx - maxMenuWidth + childSize!.width);

    final menuHeight = menuItems.length * itemExtent;
    var menuY = size.height - paddingBottom - menuHeight;
    var childY = menuY - childSize!.height - menuOffset;
    if (childY > childOffset.dy) {
      // our calculated child position is actually lower than the current position
      // of the child, adjust it and the menu upwards to keep child in same
      // position.
      final yAdjustment = childY - childOffset.dy;
      childY = childOffset.dy;
      menuY -= yAdjustment;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: blurSize ?? 4, sigmaY: blurSize ?? 4),
                  child: Container(
                    color:
                        (blurBackgroundColor ?? Colors.black).withOpacity(0.7),
                  ),
                )),
            Positioned(
              top: menuY,
              left: menuX,
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 200),
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                tween: Tween(begin: 0.0, end: 1.0),
                child: Container(
                  width: maxMenuWidth,
                  height: menuHeight,
                  decoration: menuBoxDecoration ??
                      BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          boxShadow: [
                            const BoxShadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: ListView.builder(
                      itemCount: menuItems.length,
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var item = menuItems[index];
                        Widget listItem = GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              item.onPressed();
                            },
                            child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(bottom: 1),
                                color: item.backgroundColor ?? Colors.white,
                                height: itemExtent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      item.title,
                                      if (item.trailingIcon != null) ...[
                                        item.trailingIcon!
                                      ]
                                    ],
                                  ),
                                )));
                        if (animateMenu) {
                          return TweenAnimationBuilder(
                              builder: (context, dynamic value, child) {
                                return Transform(
                                  transform: Matrix4.rotationX(1.5708 * value),
                                  alignment: Alignment.bottomCenter,
                                  child: child,
                                );
                              },
                              tween: Tween(begin: 1.0, end: 0.0),
                              duration: Duration(milliseconds: index * 200),
                              child: listItem);
                        } else {
                          return listItem;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: childY,
                left: childOffset.dx,
                child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                        width: childSize!.width,
                        height: childSize!.height,
                        child: child))),
          ],
        ),
      ),
    );
  }
}

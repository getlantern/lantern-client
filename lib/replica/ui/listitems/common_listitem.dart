import 'package:flutter/material.dart';
import 'package:lantern/i18n/i18n.dart';

// ignore: must_be_immutable
abstract class ReplicaCommonListItem extends StatefulWidget {
  ReplicaCommonListItem({
    required this.onDownloadBtnPressed,
    required this.onShareBtnPressed,
    this.onTap,
  });
  final Function() onDownloadBtnPressed;
  final Function() onShareBtnPressed;
  final Function()? onTap;
}

abstract class ReplicaCommonListItemState extends State<ReplicaCommonListItem> {
  Offset? _tapPosition;
  Widget boilerplate(Widget child) {
    return Card(
        child: InkWell(
            onTapDown: (details) {
              _tapPosition = details.globalPosition;
            },
            onTap: widget.onTap,
            onLongPress: () {
              if (_tapPosition == null) {
                return;
              }
              // XXX <11-12-2021> soltzen: From what
              // [this](https://api.flutter.dev/flutter/widgets/Element/size.html),
              // this cast will not be an issue since it is done in a gesture callback.
              final overlay = context.findRenderObject() as RenderBox;
              showMenu(
                  context: context,
                  position: RelativeRect.fromRect(
                      _tapPosition! & const Size(40, 40),
                      Offset.zero & overlay.size),
                  items: <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'download',
                      child: Text('Download'.i18n),
                      onTap: () => widget.onDownloadBtnPressed(),
                    ),
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Text('Share'.i18n),
                      onTap: () => widget.onShareBtnPressed(),
                    ),
                  ]);
            },
            child: child));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/replica/models/app_item.dart';
import 'package:lantern/vpn/vpn.dart';

class ReplicaAppListTile extends StatelessWidget {
  const ReplicaAppListTile({
    required this.appItem,
    required this.onDownloadBtnPressed,
    required this.onShareBtnPressed,
  });

  final ReplicaAppItem appItem;
  final Function() onDownloadBtnPressed;
  final Function() onShareBtnPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: PopupMenuButton(
      child: InkWell(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      appItem.displayName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                    Row(
                      children: [
                        Text(
                          appItem.humanizedLastModified,
                          style: const TextStyle(fontSize: 10.0),
                        ),
                        const Text(
                          ' - ',
                          style: TextStyle(fontSize: 10.0),
                        ),
                        Text(
                          appItem.humanizedFileSize,
                          style: const TextStyle(fontSize: 10.0),
                        ),
                      ],
                    )
                  ],
                ),
              ))),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'download',
          child: const Text('Download'),
          onTap: () => onDownloadBtnPressed(),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: const Text('Share'),
          onTap: () => onShareBtnPressed(),
        ),
      ],
    ));
  }
}

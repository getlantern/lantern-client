import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/replica/models/web_item.dart';

class ReplicaWebListTile extends StatelessWidget {
  const ReplicaWebListTile({
    required this.webItem,
    required this.onTap,
  });

  final ReplicaWebItem webItem;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: () => onTap(webItem.link),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    webItem.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                  Text(
                    webItem.displayLink,
                    style: const TextStyle(fontSize: 10.0),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                  Text(
                    webItem.snippet,
                    style: const TextStyle(fontSize: 10.0),
                  ),
                ],
              ))),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/ui/searchcategory.dart';

class UnknownItemScreen extends StatelessWidget {
  UnknownItemScreen(
      {Key? key, required this.replicaLink, required this.category});
  final ReplicaLink replicaLink;
  final SearchCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Unknown screen'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
            child: Column(children: [
          Text('Category: ${category.toString()}'),
          Text('replicaLink: ${replicaLink.toMagnetLink()}'),
        ])));
  }
}

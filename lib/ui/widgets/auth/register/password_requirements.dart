import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';

class LineItem extends ListTile {
  bool isValid = false;

  LineItem({required title, this.isValid = false})
      : super(title: title) {

  }
}

class PasswordRequirements extends StatelessWidget {

  final List<LineItem> requirements = [
    LineItem(title: Text('8 or more characters'), isValid: true),
    LineItem(title: Text('1 lowercase letter')),
    LineItem(title: Text('1 uppercase letter')),
    LineItem(title: Text('At least 1 number')),
    LineItem(title: Text('Not on a list of compromised passwords'))
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: ListTile.divideTiles(
          context: context,
          tiles: requirements,
        ).toList(),
    );
  }
}
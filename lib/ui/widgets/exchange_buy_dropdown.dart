import 'dart:ui';

import 'package:lantern/package_store.dart';

class BuyDropDownWidget extends StatefulWidget {
  final List<BuyModel> items;
  final ValueChanged<int> setBuyItem;

  BuyDropDownWidget(this.items, this.setBuyItem) : super();

  @override
  _BuyDropDownWidgetState createState() => _BuyDropDownWidgetState();
}

class _BuyDropDownWidgetState extends State<BuyDropDownWidget> {
  late BuyModel currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<BuyModel>(
      itemHeight: 56,
      value: currentValue,
      icon: const CustomAssetImage(
        path: ImagePaths.dropdown_icon,
      ),
      iconSize: 24,
      elevation: 16,
      isExpanded: true,
      style: const TextStyle(color: Colors.black, fontSize: 15),
      underline: Container(
        height: 0,
      ),
      onChanged: (BuyModel? newValue) {
        if (newValue == null) return;
        setState(() {
          currentValue = newValue;
          widget.setBuyItem(newValue.id);
        });
      },
      items: widget.items.map<DropdownMenuItem<BuyModel>>((BuyModel value) {
        return DropdownMenuItem<BuyModel>(
          value: value,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0, right: 0),
            leading: CustomAssetImage(
              path: value.icon,
            ),
            minLeadingWidth: 0,
            title: Text(value.name),
          ),
        );
      }).toList(),
    );
  }
}

class BuyModel {
  int id;
  String name;
  String icon;

  BuyModel(this.id, this.name, this.icon);

  @override
  bool operator ==(Object other) {
    return other is BuyModel && other.id == id;
  }
}

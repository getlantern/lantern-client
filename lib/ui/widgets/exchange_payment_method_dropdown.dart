import 'dart:ui';

import 'package:lantern/package_store.dart';

class MethodDropDownWidget extends StatefulWidget {
  final List<MethodModel> items;
  final ValueChanged<int> setMethodItem;

  const MethodDropDownWidget(this.items, this.setMethodItem) : super();

  @override
  _MethodDropDownWidgetState createState() => _MethodDropDownWidgetState();
}

class _MethodDropDownWidgetState extends State<MethodDropDownWidget> {
  late MethodModel currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<MethodModel>(
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
      onChanged: (MethodModel? newValue) {
        if(newValue == null) return;
        setState(() {
          currentValue = newValue;
          widget.setMethodItem(newValue.id);
        });
      },
      items:
      widget.items.map<DropdownMenuItem<MethodModel>>((MethodModel value) {
        return DropdownMenuItem<MethodModel>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}

class MethodModel {
  int id;
  String name;

  MethodModel(this.id, this.name);

  @override
  bool operator ==(Object other) {
    return other != null && other is MethodModel && other.id == this.id;
  }
}
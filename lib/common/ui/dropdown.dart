import 'package:lantern/common/common.dart';

class DropDown<T extends DropDownItem> extends StatelessWidget {
  late final String title;
  late final ValueChanged<T?> onChanged;
  late final List<T> items;
  late final T? selected;

  DropDown(
      {required this.title,
      required this.onChanged,
      this.selected,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        margin: const EdgeInsetsDirectional.only(top: 6, start: 8, end: 8),
        padding: const EdgeInsetsDirectional.only(start: 6),
        decoration: BoxDecoration(
          border: Border.all(color: grey4, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton(
            itemHeight: 56,
            value: selected ?? items.first,
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
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  leading: value.iconPath == null
                      ? null
                      : CustomAssetImage(
                          path: value.iconPath!,
                        ),
                  minLeadingWidth: 0,
                  title: Text(value.title),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      Positioned(
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            color: Colors.white,
            child: Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          )),
    ]);
  }
}

class DropDownItem<I> {
  late final I id;
  late final String title;
  late final String? iconPath;

  DropDownItem({required this.id, required this.title, this.iconPath});

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && (other as DropDownItem).id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

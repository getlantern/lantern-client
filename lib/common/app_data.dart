import 'dart:typed_data';

class AppData {
  String? name;
  String? icon;
  String? packageName;
  bool isExcluded;

  AppData(
    this.name,
    this.icon,
    this.packageName,
    this.isExcluded,
  );

  factory AppData.create(dynamic data) {
    return AppData(
      data["name"],
      data["icon"],
      data["packageName"],
      data["isExcluded"] ?? false,
    );
  }
}
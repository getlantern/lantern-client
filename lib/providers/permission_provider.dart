import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionProvider with ChangeNotifier {
  bool _isPermission = false;
  bool get isPermission => _isPermission;

  Future requestPermissions({required List<Permission> kPermissions}) async {
    return await Future.forEach(
      kPermissions,
      (Permission element) async => await element.request(),
    );
  }

  Future requestPermission(Permission permission) async => permission.request();

  Future<void> checkPermission(Permission permission) async {
    final _permissionStatus = await permission.status;
    switch (_permissionStatus) {
      case PermissionStatus.limited:
      case PermissionStatus.granted:
        _isPermission = true;
        break;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
      default:
        _isPermission = false;
        break;
    }
    notifyListeners();
  }
}

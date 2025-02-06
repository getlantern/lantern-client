// Country extension
import 'package:lantern/core/utils/common.dart';

extension CountryExtension on String {
  bool isRussia() {
    return sessionModel.country.value! == "RU";
  }
  //China
  bool isChina() {
    return sessionModel.country.value! == "CN";
  }
}

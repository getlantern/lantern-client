import 'dart:ui';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 8) {
      String hexOpacityColor = hexColor.substring(6);
      switch (hexOpacityColor) {
        case "95":
          hexOpacityColor = "F2";
          break;
        case "90":
          hexOpacityColor = "E6";
          break;
        case "85":
          hexOpacityColor = "D9";
          break;
        case "80":
          hexOpacityColor = "CC";
          break;
        case "75":
          hexOpacityColor = "BF";
          break;
        case "70":
          hexOpacityColor = "B3";
          break;
        case "65":
          hexOpacityColor = "A6";
          break;
        case "60":
          hexOpacityColor = "99";
          break;
        case "55":
          hexOpacityColor = "8C";
          break;
        case "50":
          hexOpacityColor = "80";
          break;
        case "45":
          hexOpacityColor = "73";
          break;
        case "40":
          hexOpacityColor = "66";
          break;
        case "35":
          hexOpacityColor = "59";
          break;
        case "30":
          hexOpacityColor = "4D";
          break;
        case "25":
          hexOpacityColor = "40";
          break;
        case "20":
          hexOpacityColor = "33";
          break;
        case "15":
          hexOpacityColor = "26";
          break;
        case "10":
          hexOpacityColor = "1A";
          break;
        case "05":
          hexOpacityColor = "0D";
          break;
        case "00":
          hexOpacityColor = "00";
          break;
        default:
          hexOpacityColor = "FF";
      }
      hexColor = hexOpacityColor + hexColor;
      hexColor = hexColor.substring(0, 8);
    } else if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
// 100% - FF
// 95% - F2
// 90% - E6
// 85% - D9
// 80% - CC
// 75% - BF
// 70% - B3
// 65% - A6
// 60% - 99
// 55% - 8C
// 50% - 80
// 45% - 73
// 40% - 66
// 35% - 59
// 30% - 4D
// 25% - 40
// 20% - 33
// 15% - 26
// 10% - 1A
// 5% - 0D
// 0% - 00

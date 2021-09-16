import 'messaging.dart';

class CustomAvatar extends StatelessWidget {
  const CustomAvatar({Key? key, this.id, this.displayName, this.customColor})
      : super(key: key);

  final String? id;
  final String? displayName;
  final Color? customColor;

  // For some reason, the range of hashCodes seems to fall within
  // 0 to Max Int 32 / 2. It would be nice to have some more insight into what is
  // actually generating the hashcodes, but I haven't been able to find
  // documentation on it.
  final int maxHash = 2147483647 ~/ 2;

  @override
  Widget build(BuildContext context) {
    var hash = id!.hashCode;
    var hue = max(0.0, hash / maxHash * 360);

    return CircleAvatar(
      backgroundColor: customColor ?? getAvatarColor(hue: hue),
      child: CText(
          sanitizeContactName(displayName ?? '').getInitials().toUpperCase(),
          style: tsCircleAvatarLetter),
    );
  }
}

extension StringExtensions on String {
  String getInitials() {
    // example
    // 'lionel messi' => ['lionel', 'messi'] => we pick L and M (first characters of first and last substring)
    // 'mies van der rohe' => ['mies', 'van', 'der', 'rohe'] => we pick M and R
    // 'lionelmessi' => ['l', 'i', 'o', ....] => we pick L and I (first and second)
    // 'l' => ['l'] => we only display one letter (L)
    var parts = this.split(' ');
    return parts.length > 1
        // display name contained spaces and was broken up
        ? '${parts.first.characters.first.toString()}${parts.last.characters.first.toString()}'
        // display name is a single string
        : parts.first.substring(0, parts.first.length > 1 ? 2 : 1);
  }
}

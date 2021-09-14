import 'messaging.dart';

class CustomAvatar extends StatelessWidget {
  const CustomAvatar({Key? key, this.id, this.displayName, this.customColor})
      : super(key: key);

  final String? id;
  final String? displayName;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor:
          customColor ?? avatarBgColors[id!.hashCode % avatarBgColors.length],
      child: Text(
          sanitizeContactName(displayName ?? '').getInitials().toUpperCase(),
          style: tsCircleAvatarLetter),
    );
  }
}

extension StringExtensions on String {
  String getInitials() {
    // example
    // 'kalli retzepi' => ['kalli', 'retzepi'] => we pick K and R (first characters of first and last substring)
    // 'mies van der rohe' => ['mies', 'van', 'der', 'rohe'] => we pick M and R
    // 'kalliretzepi' => ['k', 'a', 'l', ....] => we pick K and A (first and second)
    var parts = this.split(' ');
    return parts.isNotEmpty
        ? '${parts.first.characters.first.toString()}${parts.last.characters.first.toString()}'
        : parts.first.substring(0, 2);
  }
}

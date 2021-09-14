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
          sanitizeContactName(displayName ?? '').substring(0, 2).toUpperCase(),
          style: tsCircleAvatarLetter),
    );
  }
}

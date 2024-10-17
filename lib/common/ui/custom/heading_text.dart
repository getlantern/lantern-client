import '../../../core/utils/common.dart';

class HeadingText extends StatelessWidget {
  final String title;

  const HeadingText({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return CText(title, style: tsHeading1);
  }
}

class AppBarProHeader extends StatelessWidget {
  const AppBarProHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      ImagePaths.pro_logo,
      height: 16,
      fit: BoxFit.contain,
    );
  }
}

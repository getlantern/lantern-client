import 'package:lantern/core/utils/common.dart';

void showSnackbar({
  required BuildContext context,
  required dynamic content,
  Duration duration = defaultAnimationDuration,
  SnackBarAction? action,
}) {
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: content is String
              ? CText(
                  content,
                  style: tsBody1Color(white),
                  textAlign: TextAlign.start,
                )
              : content,
        ),
      ],
    ),
    action: action,
    backgroundColor: black,
    duration: duration,
    margin: const EdgeInsetsDirectional.symmetric(vertical: 16,horizontal: 8),
    padding: const EdgeInsetsDirectional.symmetric(vertical: 12,horizontal: 16),
    behavior: SnackBarBehavior.floating,
    elevation: 1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showSuerySnackbar({
  required BuildContext context,
  required String message,
  required String buttonText,
  required VoidCallback onPressed,
}) {
  final snackBar = SnackBar(
    backgroundColor: Colors.black,
    duration: const Duration(days: 99999),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsetsDirectional.symmetric(vertical: 16,horizontal: 8),
    padding: const EdgeInsetsDirectional.symmetric(vertical: 4,horizontal: 16),
    // simple way to show indefinitely
    content: CText(
      message,
      style: CTextStyle(
        fontSize: 14,
        lineHeight: 21,
        color: white,
      ),
    ),
    action: SnackBarAction(
      textColor: yellow4,
      label: buttonText.toUpperCase(),
      onPressed: onPressed,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
